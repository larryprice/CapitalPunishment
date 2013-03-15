require_relative '../../helpers/united_states_data_updater'
require_relative '../../models/state'

require 'nokogiri'

describe UnitedStatesDataUpdater do
  before :all do
    Mongoid.load! "#{File.dirname(__FILE__)}/../../mongoid.yml", :test
    Mongoid.purge!
  end

  after :all do
    Mongoid.purge!
  end

  describe "#load_data" do
    before :all do
      UnitedStatesDataUpdater.load_data
    end

    it "creates correct number of states" do
      State.where(type: "UnitedStates").count.should eql 50
    end

    it "creates Indiana state with capital of Indianapolis" do
      usa = State.find_by(name: "Indiana")
      usa.should_not be_nil
      usa.type.should eql "UnitedStates"
      usa.capital.count.should eql 1
      usa.capital.should include("Indianapolis")
    end

    it "creates California with capital of San Francisco" do
      england = State.find_by(name: "California")
      england.should_not be_nil
      england.type.should eql "UnitedStates"
      england.capital.count.should eql 1
      england.capital.should include("Sacramento")
    end

    it "creates Massachusetts with capitals of Boston" do
      swaziland = State.find_by(name: "Massachusetts")
      swaziland.should_not be_nil
      swaziland.type.should eql "UnitedStates"
      swaziland.capital.count.should eql 1
      swaziland.capital.should include("Boston")
    end

    it "creates Florida with capital of Tampa" do
      sa = State.find_by(name: "Florida")
      sa.should_not be_nil
      sa.type.should eql "UnitedStates"
      sa.capital.count.should eql 1
      sa.capital.should include("Tallahassee")
    end
  end
end
