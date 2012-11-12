$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "another_uploader/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "another_uploader"
  s.version     = AnotherUploader::VERSION
  s.authors     = ["Isaac Betesh"]
  s.email       = ["iybetesh@gmail.com"]
  s.homepage    = "http://www.github.com/betesh/another_uploader"
  s.summary     = "Upload files to your Rails App with little effort.  A newer, cleaner approach based on http://github.com/jbasdf/uploader.  Don't work with legacy code if you don't have to."
  s.description = `cat README.rdoc`

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "paperclip", "~> 3.3"
  s.add_dependency "aws-sdk", "~> 1.7"
  s.add_dependency "flash_cookie_session", "~> 1.1"
  s.add_dependency "uploadify-rails", "~> 3.1"
  s.add_dependency "best_in_place", "~> 2.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
