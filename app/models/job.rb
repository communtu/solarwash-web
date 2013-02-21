# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  device_id         :integer
#  user_id           :integer
#  program_id        :integer
#  finished          :integer
#  start_of_timespan :datetime
#  end_of_timespan   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Job < ActiveRecord::Base
  attr_accessible :device_id, :end_of_timespan, :finished, :program_id, :start_of_timespan, :user_id
  belongs_to :device
  has_one :program
  
  #scope :without_device, where(:device_id => nil)
  
  validates :finished, :inclusion => 0..2
end
