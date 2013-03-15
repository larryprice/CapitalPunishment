require_relative '../../helpers/world_data_updater'
require_relative '../../models/state'

require 'nokogiri'

describe WorldDataUpdater do
  before :all do
    Mongoid.load! "#{File.dirname(__FILE__)}/../../mongoid.yml", :test
    Mongoid.purge!
  end

  after :all do
    Mongoid.purge!
  end

  describe "#load_data" do
    before :all do
      WorldDataUpdater.load_data
    end

    it "creates United States state with capital of Washington, D.C." do
      usa = State.find_by(name: "United States")
      usa.should_not be_nil
      usa.type.should eql "World"
      usa.capital.count.should eql 1
      usa.capital.should include("Washington, D.C.")
    end

    it "creates United Kingdom with capital of London" do
      england = State.find_by(name: "United Kingdom")
      england.should_not be_nil
      england.type.should eql "World"
      england.capital.count.should eql 1
      england.capital.should include("London")
    end

    it "creates Swaziland with capitals of Mbabane and Lobamba" do
      swaziland = State.find_by(name: "Swaziland")
      swaziland.should_not be_nil
      swaziland.type.should eql "World"
      swaziland.capital.count.should eql 2
      swaziland.capital.should include("Mbabane", "Lobamba")
    end

    it "creates South Africa with capitals of Pretoria, Bloemfontein, Cape Town" do
      sa = State.find_by(name: "South Africa")
      sa.should_not be_nil
      sa.type.should eql "World"
      sa.capital.count.should eql 3
      sa.capital.should include("Pretoria", "Bloemfontein", "Cape Town")
    end
  end

  describe "#handle_special_cases" do
    it "should fix the capital of Tonga" do
      tonga = State.find_by(name: "Tonga")
      tonga.should_not be_nil
      tonga.type.should eql "World"
      tonga.capital.count.should eql 1
      tonga.capital.should include("Nuku'alofa")
    end
  end
end
