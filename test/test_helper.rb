# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase
  fixtures :all

  def self.aws_setup
    paperclip_config = AnotherUploader.configuration.has_attached_file_options
    @@bucket ||= paperclip_config[:bucket]
    AWS.config(paperclip_config[:s3_credentials])
    AWS::S3.new
  end

  def self.bucket
    @@aws ||= self.aws_setup
    @@aws.buckets[@@bucket]
  end

  def assert_remote_file_exists path
    assert self.class.bucket.objects[path].exists?, "Expected #{path} to be uploaded to bucket #{@@bucket}"
  end

  def config
    AnotherUploader.configuration
  end
end
