class ApplicationController < ActionController::Base
  protect_from_forgery
protected
  include EasyRailsAuthentication::AuthenticationHelper
  before_filter :require_authentication
end
