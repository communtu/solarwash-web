class Device < ActiveRecord::Base
  attr_accessible :name, :state, :type
end
