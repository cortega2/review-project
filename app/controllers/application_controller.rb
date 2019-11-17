class ApplicationController < ActionController::Base
  # TODO remove the active storage stuff
  # https://mikerogers.io/2018/04/13/remove-activestorage-from-rails-5-2.html
  protect_from_forgery with: :null_session
end
