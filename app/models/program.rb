class Program < ActiveRecord::Base
  attr_accessible :consumption_in_wh, :degree, :duration_in_min, :name
  has_many :jobs
end
