module AnotherUploader
  module Transliteration
    def transliterate s
      # Lifted from permalink_fu by Rick Olsen
      # Escape string using string#encode (which replaced Iconv in Ruby 1.9.3),
      # downcase, then remove illegal characters and replace them with ’-’
      s.encode('UTF-8', invalid: :replace, :undef => :replace, replace: '?').force_encoding('UTF-8')
      s.downcase!
      s.gsub!(/\'/, '')
      s.gsub!(/[^A-Za-z0-9]+/, ' ')
      s.strip!
      s.gsub!(/\ +/, '-') # set single or multiple spaces to a single dash
      s
    end

    def transliterate_file_name
      n = self.file.instance_read(:file_name)
      extension = File.extname(n)
      basename = File.basename(n, extension)
      extension = transliterate(extension)
      extension = ".#{extension}" unless extension.blank?
      initial_basename = basename
      while !self.name_is_unique?(transliterated_file_name = "#{transliterate(basename)}#{extension}")
        basename = "#{initial_basename}-#{SecureRandom.hex(4)}"
      end
      self.file.instance_write(:file_name, transliterated_file_name)
    end
  end
end
