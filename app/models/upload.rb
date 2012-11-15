require 'mime/types'
require 'paperclip'

module UploadBehavior
  MTG = AnotherUploader::MimeTypeGroups
  extend ActiveSupport::Concern

  included do
    scope :newest, order("created_at DESC")
    scope :by_filename, order("local_file_name ASC")
    scope :is_public, where('is_public = ?', true)
    image_types = comma_spliced_single_quoted(MTG::IMAGE_TYPES)
    scope :images, where("local_content_type IN (#{image_types})")
    scope :documents, where("local_content_type IN (#{comma_spliced_single_quoted(MTG::WORD_TYPES + MTG::EXCEL_TYPES + MTG::PDF_TYPES)})")
    scope :files, where("local_content_type NOT IN (#{image_types})")
    scope :recent, lambda { |*args| where("created_at > ?", args.first || 7.days.ago.to_s(:db)) }
    scope :created_by, lambda { |creator_id| where("creator_id = ?", creator_id) }
    scope :pending_s3_migrations, where("remote_file_name IS NULL").order('created_at DESC')
  end

  module ClassMethods
    def comma_spliced_single_quoted array
      array.collect{|type| "'#{type}'"}.join(',')
    end
    def file_name_exists? name
      !where("local_file_name = ? OR remote_file_name = ?", name, name).count.zero?
    end
  end

  def name_is_unique? name
    return !self.class.file_name_exists?(name) if self.new_record?
    self.class.with_scope(self.class.where('id != ?', self.id)) do
      !self.class.file_name_exists?(name)
    end
  end
end

class Upload < ActiveRecord::Base
  include Paperclip::Glue
  include UploadBehavior
  belongs_to :uploadable, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  has_attached_file :local, AnotherUploader.configuration.has_attached_file_options.merge(storage: :filesystem)
  has_attached_file :remote, AnotherUploader.configuration.has_attached_file_options
  validates_uniqueness_of :local_file_name, allow_nil: true
  validates_uniqueness_of :remote_file_name, allow_nil: true
  attr_accessible :caption, :description, :name

  before_save :add_width_and_height
  before_save :determine_immediate_send_to_remote
  before_post_process :transliterate_file_name # @TODO whole module requires unit testing
  before_post_process :halt_nonimage_processing unless AnotherUploader.configuration.enable_nonimage_processing

  def exists_locally?;	local.exists?;	end
  def exists_remotely?;	remote.exists?;	end

  def file;		file_attribute("");		end
  def file_name;	file_attribute(:file_name);	end
  def content_type;	file_attribute(:content_type);	end
  def file_size;	file_attribute(:file_size);	end
  def fingerprint;	file_attribute(:fingerprint);	end

  def file=(f)
    self.name = f.original_filename
    f.content_type = MIME::Types.type_for(name)[0].to_s
    self.remote = nil
    self.local = f
  end

  def send_to_remote
    raise Paperclip::Error, "The local file is dirty.  Please save the upload before calling send_to_remote" if local.dirty?
    if local_file_name
      self.remote = Paperclip.io_adapters.for(local)
      local.destroy if self.save && !AnotherUploader.configuration.keep_local_file && remote.exists?
    end
  end

  def icon
    self.is_image? ? self.file.url(:icon) : icon_path
  end

  def thumb
    self.file.url(:thumb) if self.is_image?
  end

  def can_edit?(user)
    !user.blank? && user == self.creator
  end

  def width(style = :default); dimension :width, style; end

  def height(style = :default); dimension :height, style; end

  def size(style = :default)
    return nil unless width || height
    return "#{width}x#{height}" if style == :default
    calculate_sizes(style.to_sym)
    return @image_size
  end

private :remote=, :local=, :remote, :local
private
  include AnotherUploader::Icons
  include AnotherUploader::ImageProcessing
  include AnotherUploader::MimeTypeGetters
  include AnotherUploader::Transliteration

  def determine_immediate_send_to_remote
    config = AnotherUploader.configuration
    if config.enable_s3 && config.s3_no_wait
      self.remote = queued_for_write
      self.local = nil unless config.keep_local_file
    end
    true
  end

  def queued_for_write
    self.file.queued_for_write[:original]
  end

  def add_width_and_height
    return unless self.is_image?
    queued_file = queued_for_write
    if queued_file
      geometry = Paperclip::Geometry.from_file queued_file
      self[:width] = geometry.width.to_i
      self[:height] = geometry.height.to_i
    end
  end

  def halt_nonimage_processing
    is_image?
  end

  def file_attribute attr
    self.__send__("#{local_file_name ? :local : :remote}#{:_ if !attr.blank?}#{attr}")
  end
end
