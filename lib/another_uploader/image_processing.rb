module AnotherUploader
  module ImageProcessing
    def dimension dim, style
      return nil unless self[dim]
      return self[dim] if style == :default
      calculate_sizes(style.to_sym)
      return instance_variable_get("@image_#{dim}").to_i
    end

    def image_ratio
      @image_ratio ||= width.to_f / height.to_f
    end

    def max_dimension(style)
      @max_dimension ||= Paperclip::Geometry.parse(self.local.styles[style][:geometry]).width.to_f
    end

    def calculate_sizes(style)
      if image_ratio > 1
        @image_width ||= [width, max_dimension(style)].min
        @image_height ||= (@image_width / image_ratio).round
      else
        @image_height ||= [height, max_dimension(style)].min
        @image_width ||= (@image_height * image_ratio).round
      end
      @image_size ||= "#{@image_width.to_i}x#{@image_height.to_i}"
    end
  end
end
