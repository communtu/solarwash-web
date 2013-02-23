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
  #before_validation :check_end_of_timespans
  
  attr_accessible :device_id, :end_of_timespan, :finished,
                  :program_id, :start_of_timespan, :user_id,
                  :start, :confirm
  
  def to_param
    [id, "job"].join("-")
  end
                  
  belongs_to :device
  has_one :program
  
  validates :start, :presence   => true
  #scope :without_device, where(:device_id => nil)
  
  private
  
  def check_end_of_timespans
    return false if end_of_timespan < DateTime.now + 3.hours
  end
end
