require 'upload_test_helper'

module EasyRailsAuthentication
  module AuthenticationHelper
    alias_method :protected_log_in_as, :log_in_as
    def log_in_as user
      protected_log_in_as user
    end
  end
end

class ActionController::TestCase
  include UploadTestHelperModule
  setup do
    @upload = Upload.new
    @controller.log_in_as users(:plain)
  end

  teardown do
    Upload.destroy_all
  end
end
