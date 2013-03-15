require 'rake'

task :default => [:start]

desc "Run all spec tests"
task :spec do
  Dir.glob("#{File.dirname(__FILE__)}/test/spec/*_spec.rb") do |file|
    ruby "-S rspec --color #{file}"
  end
end

desc "Start application using webrick on port 9292"
task :start do
  unless ENV['RACK_ENV'] == :production
    ruby "-S bundle exec rackup -s webrick -p 9292"
  else
    ruby "-S bundle exec rackup -s webrick -p 9292"
  end
end

desc "Clean the given database, development by default"
require 'mongoid'
require_relative 'models/state'
task :clean_db, :env do |t, args|
  args.with_defaults(:env => :development)
  Mongoid.load! "#{File.dirname(__FILE__)}/mongoid.yml", args[:env].to_sym
  State.delete_all
end

desc "Update the database by scraping data from the web, development by default"
require 'mongoid'
require './helpers/world_data_updater'
require './helpers/united_states_data_updater'
require './helpers/canada_data_updater'
require './helpers/mexico_data_updater'
task :update_db, :env do |t, args|
  args.with_defaults(:env => :development)
  Mongoid.load! "#{File.dirname(__FILE__)}/mongoid.yml", args[:env].to_sym
  WorldDataUpdater.load_data
  UnitedStatesDataUpdater.load_data
  CanadaDataUpdater.load_data
  MexicoDataUpdater.load_data
end
