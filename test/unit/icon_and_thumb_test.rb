require 'upload_test_helper'

class IconAndThumbTest < UploadTestHelper
  def for_each_non_image_file_when_uploaded &block
    NON_IMAGE_FILES.each { |file|
      when_i_upload_a file
      @upload.save!
      yield file
    }
  end

  def given_an_uploaded_image
    when_i_upload_a IMAGE
    @upload.save!
  end

  test "can get icon for image" do
    given_an_uploaded_image
    assert_equal @upload.file.url(:icon), @upload.icon
  end
  test "can get icon for other files" do
    for_each_non_image_file_when_uploaded { |file|
      assert_match /^another_uploader\/.{3,}\.gif$/, @upload.icon
      assert Rails.application.assets.find_asset(@upload.icon), Rails.application.config.assets.paths.inspect
    }
  end
  test "can get thumb for image" do
    given_an_uploaded_image
    assert_equal @upload.file.url(:thumb), @upload.thumb
  end
  test "thumb is nil for non-image" do
    for_each_non_image_file_when_uploaded { |file|
      assert_nil @upload.thumb
    }
  end
end
