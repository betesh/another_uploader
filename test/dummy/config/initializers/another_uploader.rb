AnotherUploader.configure do |config|
  config_file = "#{::Rails.root}/config/s3.yml"
  if !File.exists?(config_file)
    puts "Please create #{config_file}"
    puts "Sample file located at #{config_file}.example"
    exit
  end
  s3 =  YAML.load_file(config_file)[Rails.env].symbolize_keys
  config.has_attached_file_options.merge!({storage: :s3, s3_credentials: s3[:credentials], bucket: s3[:bucket]})
end
