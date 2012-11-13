require EasyRailsAuthentication::Engine.config.root + 'app' + 'models' + 'user'

class User
  has_many :files, class_name: "Upload"
end

