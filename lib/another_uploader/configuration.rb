module AnotherUploader
  def self.configuration
    @configuration ||= Configuration.new
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :has_attached_file_options
    attr_accessor :enable_s3
    attr_accessor :s3_no_wait
    attr_accessor :keep_local_file
    attr_accessor :enable_nonimage_processing
    attr_accessor :temp_dir

    def initialize
      @enable_s3 = false
      @s3_no_wait = false
      @keep_local_file = true
      @enable_nonimage_processing = false
      @temp_dir = Dir::tmpdir
      @has_attached_file_options = {
        url: "/system/:attachment/:id_partition/:style/:filename",
        path: ":rails_root/public:url", 
        styles: { icon: "30x30!", thumb: "100>", small: "150>", medium: "300>", large: "660>" },
        default_url: "/images/default.jpg",
        convert_options: { all: '-quality 80' }
      }
    end
  end
end
