class Upload < ActiveRecord::Base
  attr_accessible :caption, :creator_id, :description, :height, :is_public, :local_content_type, :local_file_name, :local_file_size, :local_fingerprint, :local_updated_at, :name, :remote_content_type, :remote_file_name, :remote_file_size, :remote_fingerprint, :remote_updated_at, :uploadable_id, :uploadable_type, :width
end
