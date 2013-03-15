require_relative '../../helpers/mexico_data_updater'
require_relative '../../models/state'

require 'nokogiri'

describe MexicoDataUpdater do
  before :all do
    Mongoid.load! "#{File.dirname(__FILE__)}/../../mongoid.yml", :test
    Mongoid.purge!
  end

  after :all do
    Mongoid.purge!
  end

  describe "#load_data" do
    before :all do
      MexicoDataUpdater.load_data
    end

    it "creates correct number of provinces" do
      State.where(type: "Mexico").count.should eql 31
    end

    it "creates Aguascalientes state with capital of Aguascalientes" do
      state = State.find_by(name: "Aguascalientes")
      state.should_not be_nil
      state.type.should eql "Mexico"
      state.capital.count.should eql 1
      state.capital.should include("Aguascalientes")
    end

    it "creates Guerrero with capital of Chilpancingo" do
      state = State.find_by(name: "Guerrero")
      state.should_not be_nil
      state.type.should eql "Mexico"
      state.capital.count.should eql 1
      state.capital.should include("Chilpancingo")
    end

    it "creates Tamaulipas with capital of Ciudad Victoria" do
      state = State.find_by(name: "Tamaulipas")
      state.should_not be_nil
      state.type.should eql "Mexico"
      state.capital.count.should eql 1
      state.capital.should include("Ciudad Victoria")
    end
  end
end
