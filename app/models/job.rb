# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  device_id         :integer
#  user_id           :integer
#  program_id        :integer
#  finished          :integer
#  confirm           :boolean
#  start_of_timespan :datetime
#  end_of_timespan   :datetime
#  start             :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Job < ActiveRecord::Base
  before_validation :check_end_of_timespans
  
  attr_accessible :device_id, :end_of_timespan, :finished,
                  :program_id, :start_of_timespan, :user_id,
                  :start, :confirm
  
  def to_param
    [id, "job"].join("-")
  end
                  
  belongs_to :device
  has_one :program
  
  #scope :without_device, where(:device_id => nil)


  def self.update_job_status
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    
    Device.all.each do |d|
      d.jobs.find(:all, :conditions => ["finished == ?", 0]).each do |j|
        if (j.start.to_datetime + Program.find(j.program_id).duration_in_min.minute) <= DateTime.now
          j.update_attributes(:finished => 1)
        end
      end
      if d.jobs.find(:all, :conditions => ["finished == ?", 0]).count == 0
        d.update_attributes(:state => 0)
      end
    end
    
  end
  
  private
  
  def check_end_of_timespans
    return false if end_of_timespan < DateTime.now + (Program.find(device_id).duration_in_min).minute
  end
end
