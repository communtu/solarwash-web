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

#!/bin/env ruby
# encoding: utf-8
class Job < ActiveRecord::Base
  
  #before_validation :check_end_of_timespans
  
  attr_accessible :device_id, :end_of_timespan, :finished,
                  :program_id, :start_of_timespan, :user_id,
                  :start, :confirm, :is_running, :time_to_confirm
  
  #def to_param
  #  [id, "job"].join("-")
  #end
                  
  belongs_to :device
  has_one :program
  
  validates :program_id, presence: {message: "Kein Programm ausgewaehlt"}
  validate :check_end_of_timespans
  #scope :without_device, where(:device_id => nil)


  def self.update_job_status
    puts "Start: update_job_status - #{DateTime.now}"
    Device.all.each do |d|
      d.jobs.find(:all, conditions: ["finished = ?", 0]).each do |j|
        if (j.start.to_datetime + Program.find(j.program_id).duration_in_min.minute) <= DateTime.now &&
            j.confirm == true
          if j.update_attribute('finished', 1)
            j.update_attributes(is_running: false)
            d.update_attribute('state', 1)
            UserMailer.job_finished_email(User.find(j.user_id), 
                                          Device.find(j.device_id),
                                          Program.find(j.program_id)).deliver
            puts "Device: #{d.name}, Job_id: #{j.id} wurde auf beendet gesetzt"
          else
            puts "Fehler beim Beenden von Device: #{d.name}, Job_id: #{j.id}"
          end
        end
      end
      if d.jobs.find(:all, conditions: ["finished = ?", 0]).count == 0
        if d.update_attributes(state: 0)
          puts "Status von Device: #{d.name} wurde auf 0 gesetzt"
        else
          puts "Fehler beim Status auf 0 setzen von Device: #{d.name}"
        end
      end
    end
    puts "END: update_job_status"
  end
  
  def self.shift_jobs
    puts "Start: shift_jobs - #{DateTime.now}"
    Device.all.each do |d|
      first_job = d.jobs.order("id ASC").limit(1).find(:all, conditions: ["finished = ?", 0])[0]
      
      if first_job != nil && first_job.start.to_datetime < DateTime.now &&
         !first_job.confirm
        
          #Ueberpruefung ob Zeit fuer Confirm abgelaufen ist
          setting_time_to_confirm = Setting.find(1).time_to_confirm
          if first_job.time_to_confirm == nil
            first_job.update_attribute('time_to_confirm', setting_time_to_confirm)
          else
            first_job.update_attribute('time_to_confirm', first_job.time_to_confirm-1)
          end

          if first_job.time_to_confirm <= 0 
            puts "shift_jobs: time_to_confirm abgelaufen => Loeschen"
            id = first_job.id
            user_id = first_job.user_id
            device_id = first_job.device_id
            program_id = first_job.program_id
            first_job.destroy
            
            UserMailer.confirm_time_has_expired_mail( User.find(user_id), 
                                                      Device.find(device_id),
                                                      Program.find(program_id)).deliver
                                                      
            if d.jobs.count == 0
              d.update_attributes(state: 0)
            else
              ConflictHelper.delete_management(d, id)
            end
          else
            puts "shift_jobs: time_to_confirm nicht abgelaufen => Shifting"
            ConfirmHelper.confirm_shift_first_job(first_job)
            jobs_to_shift = d.jobs.find(:all, conditions: ["finished = ?", 0])
            ConfirmHelper.confirm_shift_all_jobs(jobs_to_shift)
          end
      elsif first_job != nil && first_job.start.to_datetime < DateTime.now &&
            first_job.confirm && !first_job.is_running
          ConflictHelper.start_now(d, first_job)
      end
    end
    puts "END: shift_jobs"
  end
  
  private
  
  def check_end_of_timespans
    if end_of_timespan == nil
      errors.add(:end_of_timespan, "Du musst eine Zeit eingeben")
    else
      minimum_end_of_timespan = JobsHelper.errormsg_end_of_timespan(self.device_id, self)
      if end_of_timespan.to_datetime < minimum_end_of_timespan.to_datetime
        errors.add(:end_of_timespan, "Deine Waesche kann fruehestens um #{minimum_end_of_timespan.to_time.strftime('%H:%M')}Uhr fertig werden!")
      end
    end
  end
  
  #def check_end_of_timespans
  #  if end_of_timespan < DateTime.now + (Program.find(device_id).duration_in_min).minute
  #    return false 
  #  else
  #    return true
  #  end
  #end
end
