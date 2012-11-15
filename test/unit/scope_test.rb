require 'upload_test_helper'

class ScopeTest < UploadTestHelper
  include FileUtils
  setup do
    each_of_10_files { |file|
      cp("#{fixture_path}/files/#{TEXT[:name]}", file)
    }
  end

  teardown do
    each_of_10_files { |file|
      rm file
    }
  end

  def upload_another file, is_public=true
    upload = Upload.new
    upload.is_public = is_public
    upload.file = Rack::Test::UploadedFile.new(file)
    upload.save!
  end

  def each_of_10_files &block
    ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth'].each { |name|
      path = "#{Dir::tmpdir}/#{name}-#{TEXT[:name]}"
      yield path
    }
  end

  def when_i_upload_10_files
    pub = false
    each_of_10_files { |file|
      pub = !pub
      upload_another file, pub
    }
  end

  def when_i_upload_all_file_types
    ALL_FILES.each { |file|
      @upload = Upload.new
      when_i_upload_a file
      @upload.save!
    }
  end

  def assert_correct_files_retrieved
    assert_equal @expected.size, @actual.size
    @expected_names ||= @expected.collect { |f| f[:name] }
    @actual.each { |f|
      assert @expected_names.include?(f.file_name), "Expected #{f.file_name} to be in the list: #{@expected_names.inspect}"
    }
  end

  test "newest" do
    when_i_upload_10_files
    newest = Upload.newest.limit(5)
    assert_equal "tenth-#{TEXT[:name]}", newest[0].file_name
    assert_equal "ninth-#{TEXT[:name]}", newest[1].file_name
    assert_equal "eighth-#{TEXT[:name]}", newest[2].file_name
    assert_equal "seventh-#{TEXT[:name]}", newest[3].file_name
    assert_equal "sixth-#{TEXT[:name]}", newest[4].file_name
  end

  test "alphabetical" do
    when_i_upload_10_files
    alphabetical = Upload.by_filename.limit(5)
    assert_equal "eighth-#{TEXT[:name]}", alphabetical[0].file_name
    assert_equal "fifth-#{TEXT[:name]}", alphabetical[1].file_name
    assert_equal "first-#{TEXT[:name]}", alphabetical[2].file_name
    assert_equal "fourth-#{TEXT[:name]}", alphabetical[3].file_name
    assert_equal "ninth-#{TEXT[:name]}", alphabetical[4].file_name
  end

  test "is public" do
    @expected = @expected_names = [:first, :third, :fifth, :seventh, :ninth].collect { |ord| "#{ord}-#{TEXT[:name]}"}
    when_i_upload_10_files
    @actual = Upload.is_public
    assert_correct_files_retrieved
  end

  test "images" do
    @expected = [IMAGE]
    when_i_upload_all_file_types
    @actual = Upload.images
    assert_correct_files_retrieved
  end

  test "files" do
    @expected = NON_IMAGE_FILES
    when_i_upload_all_file_types
    @actual = Upload.files
    assert_correct_files_retrieved
  end

  test "documents" do
    @expected = [PDF, DOC, SPREADSHEET]
    when_i_upload_all_file_types
    @actual = Upload.documents
    assert_correct_files_retrieved
  end

  test "recent" do
    first_group = ['first', 'third', 'fourth', 'seventh', 'eighth', 'ninth']
    second_group = ['second', 'fifth', 'sixth', 'tenth']
    @expected = @expected_names = second_group.collect { |ord| "#{ord}-#{TEXT[:name]}"}

    first_group.each { |name|
      path = "#{Dir::tmpdir}/#{name}-#{TEXT[:name]}"
      upload_another path
    }
    sleep 3
    second_group.each { |name|
      path = "#{Dir::tmpdir}/#{name}-#{TEXT[:name]}"
      upload_another path
    }

    @actual = Upload.recent(Time.now - 3.seconds)
    assert_correct_files_retrieved
  end

  test "created_by" do
    @plain = users(:plain)
    @admin = users(:admin)

    @upload = Upload.new
    @upload.creator = @plain
    when_i_upload_a IMAGE
    @upload.save!
    @upload = Upload.new
    @upload.creator = @admin
    when_i_upload_a PDF
    @upload.save!
    @upload = Upload.new
    @upload.creator = @admin
    when_i_upload_a DOC
    @upload.save!

    @expected = [IMAGE]
    @actual = Upload.created_by(@plain.id)
    assert_correct_files_retrieved

    @expected_names = nil
    @expected = [PDF, DOC]
    @actual = Upload.created_by(@admin.id)
    assert_correct_files_retrieved
  end

  test "pending_s3_migrations" do
    others = [IMAGE, SPREADSHEET, TEXT, NONE]
    @expected = [PDF, DOC, MP3]
    given_s3_is_deferred
    when_i_upload_all_file_types
    others.each { |file|
      Upload.find_by_name(file[:name]).send_to_remote
    }

    @actual = Upload.pending_s3_migrations
    assert_correct_files_retrieved
  end
end
