require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  test "should get uploadify" do
    get :uploadify
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
