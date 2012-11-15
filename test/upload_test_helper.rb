require 'test_helper'

class UploadTestHelper < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  IMAGE = { name: 'lorem-ipsum.jpg', type: 'image/jpeg', size: 54640, fingerprint: "c7620915083b8aefa8780bda998eaa20" }
  PDF = { name: 'lorem-ipsum.pdf', type: 'application/pdf', size: 41241, fingerprint: "261fbfc6fd78b35df6cfebb40f63ac64" }
  DOC = { name: 'lorem-ipsum.odt', type: 'application/vnd.oasis.opendocument.text', size: 14759, fingerprint: "77c548ba9ed255e649bfa1103c2bcf06" }
  MP3 = { name: '1000hz-5sec.mp3', type: 'audio/mpeg', size: 30440, fingerprint: "424d82cf66903c16ccdf17caab51113f" }
  SPREADSHEET = { name: 'lorem-ipsum.ods', type: 'application/vnd.oasis.opendocument.spreadsheet', size: 11089, fingerprint: "b7c8e4c229268fdb633a3d08e26e9079" }
  TEXT = { name: 'lorem-ipsum.txt', type: 'text/plain', size: 2816, fingerprint: "1ce9b5516c33e853fa1ef05730d57c7d" }
  NONE = { name: 'lorem-ipsum', type: '', size: 2816, fingerprint: "1ce9b5516c33e853fa1ef05730d57c7d" }
  NON_IMAGE_FILES = [PDF, DOC, MP3, SPREADSHEET, TEXT, NONE]
  ALL_FILES = [IMAGE, PDF, DOC, MP3, SPREADSHEET, TEXT, NONE]

  setup do
    @upload = Upload.new
  end

  teardown do
    Upload.destroy_all
  end

  def fixture_file type
    fixture_file_upload("/files/#{type[:name]}")
  end

  def file_at name, type
    fixture_file_upload("/files/#{name}", type)
  end

  def when_i_upload_a file
    @upload.file = file_at(file[:name], file[:type])
    assert !@upload.file.exists?
  end

  def given_s3_is_immediate
    config.enable_s3 = true
    config.s3_no_wait = true
    config.keep_local_file = false
  end

  def given_s3_is_deferred
    config.enable_s3 = true
    config.s3_no_wait = false
    config.keep_local_file = false
  end

  def given_s3_is_disabled
    config.enable_s3 = false
  end
end
