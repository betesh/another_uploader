require 'upload_test_helper'

class NameTest < UploadTestHelper
  def duplicate_of file
    /^#{File.basename(file[:name], File.extname(file[:name]))}-[a-f0-9]{8}#{File.extname(file[:name])}$/
  end

  def assert_matches_duplicate_of file, actual
    assert_match duplicate_of(file), actual, actual
  end

  def when_i_upload_files_with_matching_names
    (1..2).each {
      @upload = Upload.new
      when_i_upload_a PDF
      @upload.save!
    }
  end

  test "file_name is used as name" do
    when_i_upload_a PDF
    assert_equal PDF[:name], @upload.name
    assert_equal PDF[:name], @upload.file_name
  end

  test "files with matching names use random hashes to distinguish file names" do
    when_i_upload_files_with_matching_names
    uploads = Upload.all
    assert_equal 2, uploads.size

    file_names = uploads.collect { |u| u.file_name }
    assert file_names.include?(PDF[:name])
    file_names.delete(PDF[:name])
    assert_matches_duplicate_of PDF, file_names[0]

    names = uploads.collect { |u| u.name }
    assert_equal [PDF[:name], PDF[:name]], names, names
  end

  test "file_name reused when sending to remote" do
    given_s3_is_deferred
    config.keep_local_file = true

    when_i_upload_a PDF
    @upload.save!
    @upload.send_to_remote
    assert_equal PDF[:name], @upload.local_file_name
    assert_equal PDF[:name], @upload.remote_file_name

    @upload = Upload.new
    when_i_upload_a PDF
    @upload.save!
    @upload.send_to_remote
    assert_matches_duplicate_of PDF, @upload.local_file_name
    assert_equal @upload.local_file_name, @upload.remote_file_name
  end
end

class TransliteratedDuplicateNameTest < NameTest
  include FileUtils
  def upper_path file
    "#{Dir::tmpdir}/#{file[:name].upcase}"
  end

  setup do
    ALL_FILES.each { |file|
      cp("#{fixture_path}/files/#{file[:name]}", upper_path(file))
    }
  end

  teardown do
    ALL_FILES.each { |file|
      rm upper_path(file)
    }
  end

  def upload_from path
    upload = Upload.new
    upload.file = Rack::Test::UploadedFile.new(path)
    upload.save!
  end

  test "searches for transliterated name when checking for duplicate of each type" do
    ALL_FILES.each { |file|
      path = upper_path(file)
      upload_from path
      upload_from path
      file_names = Upload.where(name: file[:name].upcase).collect{ |u| u.file_name }
      assert_equal 2, file_names.size, "Expected #{Upload.select(:name)} to include #{file[:name].upcase}"
      assert file_names.include?(file[:name]), "Expcted #{file_names.inspect} to include #{file[:name]}"
      file_names.delete_if { |v| file[:name] == v }
      assert_matches_duplicate_of file, file_names[0]
    }
  end
end
