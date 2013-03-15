require_relative '../../helpers/canada_data_updater'
require_relative '../../models/state'

require 'nokogiri'

describe CanadaDataUpdater do
  before :all do
    Mongoid.load! "#{File.dirname(__FILE__)}/../../mongoid.yml", :test
    Mongoid.purge!
  end

  after :all do
    Mongoid.purge!
  end

  describe "#load_data" do
    before :all do
      CanadaDataUpdater.load_data
    end

    it "creates correct number of provinces" do
      State.where(type: "Canada").count.should eql 13
    end

    it "creates Ontario state with capital of Toronto" do
      usa = State.find_by(name: "Ontario")
      usa.should_not be_nil
      usa.type.should eql "Canada"
      usa.capital.count.should eql 1
      usa.capital.should include("Toronto")
    end

    it "creates Nova Scotia with capital of Halifax" do
      england = State.find_by(name: "Nova Scotia")
      england.should_not be_nil
      england.type.should eql "Canada"
      england.capital.count.should eql 1
      england.capital.should include("Halifax")
    end

    it "creates Prince Edward Island with capitals of Charlottetown" do
      swaziland = State.find_by(name: "Prince Edward Island")
      swaziland.should_not be_nil
      swaziland.type.should eql "Canada"
      swaziland.capital.count.should eql 1
      swaziland.capital.should include("Charlottetown")
    end

    it "creates Newfoundland and Labrador with capital of St. John's" do
      sa = State.find_by(name: "Newfoundland and Labrador")
      sa.should_not be_nil
      sa.type.should eql "Canada"
      sa.capital.count.should eql 1
      sa.capital.should include("St. John's")
    end

    it "creates Yukon with capital of Whitehorse" do
      sa = State.find_by(name: "Yukon")
      sa.should_not be_nil
      sa.type.should eql "Canada"
      sa.capital.count.should eql 1
      sa.capital.should include("Whitehorse")
    end
  end
end
