module AnotherUploader
  class Engine < ::Rails::Engine
    initializer 'image magick must be installed' do
      convert = `which convert`
      if "" == convert
        puts "imagemagick must be installed for the tests to run."
        puts "Please execute `sudo apt-get install imagemagick` and then try again"
        exit
      end
    end
  end
end
