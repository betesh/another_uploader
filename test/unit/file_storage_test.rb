require 'upload_test_helper'

class FileStorageTest < UploadTestHelper
  setup do
    @path_to_created_files = File.dirname(__FILE__)+"/../dummy/public/system"
    given_s3_is_disabled
  end

  def each_style &block
    config.has_attached_file_options[:styles].keys.each { |style|
      yield style
    }
  end

  def attachment_path filename, style
    "000/000/001/#{style}/#{filename}"
  end

  def remote_path filename, style
    "remotes/#{attachment_path filename, style}"
  end

  def local_path filename, style
    "#{@path_to_created_files}/locals/#{attachment_path filename, style}"
  end

  def assert_each_style_was_saved_on_s3_for file
    each_style { |style|
      assert_remote_file_exists remote_path(file[:name], style)
    }
    assert_remote_file_exists remote_path(file[:name], :original)
  end

  def assert_only_original_was_saved_on_filesystem_for file
    assert_file_saved_on_local_filesystem file[:name], :original
    each_style { |style|
      path = local_path file[:name], style
      assert !File.file?(path), "Expected no file to exist at #{path}"
    }
  end

  def assert_file_saved_on_local_filesystem name, style
    path = local_path name, style
    assert File.file?(path), "Expected file to be uploaded to #{path}"
  end

  def assert_each_style_was_saved_on_filesystem_for file
    each_style { |style|
      assert_file_saved_on_local_filesystem file[:name], style
    }
    assert_file_saved_on_local_filesystem file[:name], :original
  end

  def assert_the_file_only_exists_locally
    assert @upload.exists_locally?, "The file should exist locally"
    assert !@upload.exists_remotely?, "The file should not exist remotely"
  end

  def assert_the_file_only_exists_remotely
    assert !@upload.exists_locally?, "The file should not exist locally"
    assert @upload.exists_remotely?, "The file should exist remotely"
  end

  def assert_dimensions
    assert_equal 503, @upload.width
    assert_equal 350, @upload.height
    assert_equal "503x350", @upload.size
  end

  def assert_file_attributes_match original
    assert_equal original[:name], @upload.file_name, original.inspect
    assert_equal original[:type], @upload.content_type, original.inspect
    assert_equal original[:size], @upload.file_size, original.inspect
    assert_equal original[:fingerprint], @upload.fingerprint, original.inspect
  end

  def when_i_upload_to_s3_a file
    given_s3_is_immediate
    when_i_upload_a file
  end

  test "can upload an image to local filesystem" do
    when_i_upload_a IMAGE
    assert @upload.save, @upload.errors.messages.inspect
    assert_the_file_only_exists_locally
    assert_each_style_was_saved_on_filesystem_for IMAGE
    assert_file_attributes_match IMAGE
    assert_dimensions
  end

  test "can upload an image directly to s3" do
    when_i_upload_to_s3_a IMAGE
    assert @upload.save, @upload.errors.messages.inspect
    assert_the_file_only_exists_remotely
    assert_each_style_was_saved_on_s3_for IMAGE
    assert_file_attributes_match IMAGE
    assert_dimensions
  end

  test "can move an image from local filesystem to s3" do
    given_s3_is_deferred
    when_i_upload_a IMAGE
    @upload.save!
    assert_the_file_only_exists_locally
    @upload.send_to_remote
    assert_the_file_only_exists_remotely
    assert_each_style_was_saved_on_s3_for IMAGE
    assert_file_attributes_match IMAGE
    assert_dimensions
  end

  test "can upload non-image types to local filesystem" do
    NON_IMAGE_FILES.each { |file|
      when_i_upload_a file
      assert @upload.save, @upload.errors.messages.inspect
      assert_the_file_only_exists_locally
      assert_file_attributes_match file
      assert_only_original_was_saved_on_filesystem_for file
    }
  end

  test "content type can be inferred when uploading" do
    given_s3_is_disabled
    ALL_FILES.each { |file|
      @upload.file = fixture_file(file)
      assert_file_attributes_match file
    }
  end

  test "can_edit? compares creator to a user" do
    @user = users(:plain)
    @upload.creator = @user
    when_i_upload_a PDF
    assert @upload.can_edit?(@user)
    assert !@upload.can_edit?(users(:admin))
  end

  test "can_edit? returns false when creator is nil" do
    when_i_upload_a PDF
    assert !@upload.can_edit?(users(:plain))
    assert !@upload.can_edit?(users(:admin))
    assert !@upload.can_edit?(@upload.creator)
    assert !@upload.can_edit?('')
  end

  test "cannot send dirty file to remote" do
    given_s3_is_deferred
    when_i_upload_a DOC
    assert_raise Paperclip::Error do
      @upload.send_to_remote
    end
    @upload.save!
    assert_the_file_only_exists_locally
    @upload.send_to_remote
    assert_the_file_only_exists_remotely
  end
end
