# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if ENV['HTTP_AUTH'] == 'true'
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['HTTP_USER'] && password == ENV['HTTP_PASSWORD']
  end
end

run Rails.application
