class Job < ActiveRecord::Base
  attr_accessible :device_id, :end_of_timespan, :finished, :program_id, :start_of_timespan, :user_id
  belongs_to :device
  has_one :program
end
