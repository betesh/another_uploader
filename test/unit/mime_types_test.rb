require 'upload_test_helper'

class MimeTypesTest < UploadTestHelper
  test "image knows its type" do
    when_i_upload_a IMAGE
    assert @upload.is_image?

    assert !@upload.is_pdf?
    assert !@upload.is_word?
    assert !@upload.is_mp3?
    assert !@upload.is_excel?
    assert !@upload.is_text?
  end
  test "pdf knows its type" do
    when_i_upload_a PDF
    assert @upload.is_pdf?

    assert !@upload.is_image?
    assert !@upload.is_word?
    assert !@upload.is_mp3?
    assert !@upload.is_excel?
    assert !@upload.is_text?
  end
  test "doc knows its type" do
    when_i_upload_a DOC
    assert @upload.is_word?

    assert !@upload.is_image?
    assert !@upload.is_pdf?
    assert !@upload.is_mp3?
    assert !@upload.is_excel?
    assert !@upload.is_text?
  end
  test "mp3 knows its type" do
    when_i_upload_a MP3
    assert @upload.is_mp3?

    assert !@upload.is_image?
    assert !@upload.is_pdf?
    assert !@upload.is_word?
    assert !@upload.is_excel?
    assert !@upload.is_text?
  end
  test "spreadsheet knows its type" do
    when_i_upload_a SPREADSHEET
    assert @upload.is_excel?

    assert !@upload.is_image?
    assert !@upload.is_pdf?
    assert !@upload.is_word?
    assert !@upload.is_mp3?
    assert !@upload.is_text?
  end
  test "text file knows its type" do
    when_i_upload_a TEXT
    assert @upload.is_text?

    assert !@upload.is_image?
    assert !@upload.is_pdf?
    assert !@upload.is_word?
    assert !@upload.is_mp3?
    assert !@upload.is_excel?
  end
  test "raw file knows it has no type" do
    when_i_upload_a NONE

    assert !@upload.is_image?
    assert !@upload.is_pdf?
    assert !@upload.is_word?
    assert !@upload.is_mp3?
    assert !@upload.is_excel?
    assert !@upload.is_text?
  end
end
