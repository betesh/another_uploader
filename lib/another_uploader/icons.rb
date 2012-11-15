module AnotherUploader
  module Icons
    def icon_path
      "another_uploader/#{icon_name}.gif"
    end

    def icon_name
      if self.is_pdf?
        :pdf
      elsif self.is_word?
        :doc
      elsif self.is_mp3?
        :mp3
      elsif self.is_excel?
        :spreadsheet
      elsif self.is_text?
        :text
      else
        :none
      end
    end
  end
end
