require 'mongoid'

class State
  include Mongoid::Document

  field :name, type: String
  field :capital, type: Array

  field :type, type: String
end
