require 'functional_test_helper'

class UploadsControllerTest < ActionController::TestCase
  def given_an_upload
    when_i_upload_a TEXT
    @upload.save!
  end

  test "should get uploadify" do
    post :uploadify, format: :js
    assert_response :success
  end

  test "should get destroy" do
    given_an_upload
    delete :destroy, format: :js, id: @upload.id
    assert_response :success
  end
end
