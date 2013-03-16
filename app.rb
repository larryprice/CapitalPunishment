require 'sinatra/base'

class CapitalPunishment < Sinatra::Base
end

# require all controllers
Dir.glob("#{File.dirname(__FILE__)}/controllers/*.rb").each do |file|
  require file.chomp(File.extname(file))
end

class CapitalPunishment
  get '/' do
    redirect :World
  end

  not_found do
    redirect '/'
  end
end
