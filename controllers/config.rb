require 'mongoid'

class CapitalPunishment
  configure do
    enable :sessions, :logging

    Mongoid.load! "#{File.dirname(__FILE__)}/../mongoid.yml"
  end
end
