require "another_uploader/mime_type_groups"

module AnotherUploader
  module MimeTypeGetters
    MTG = MimeTypeGroups
    def is_of_type? type_list
      type_list.include?(self.local_content_type)
    end

    def is_image?; is_of_type?(MTG::IMAGE_TYPES); end
    def is_pdf?; is_of_type?(MTG::PDF_TYPES); end
    def is_word?; is_of_type?(MTG::WORD_TYPES); end
    def is_mp3?; is_of_type?(MTG::MP3_TYPES); end
    def is_excel?; is_of_type?(MTG::EXCEL_TYPES); end
    def is_text?; is_of_type?(MTG::TEXT_TYPES); end
  end
end
