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
  
  #def to_param
  #  [id, "job"].join("-")
  #end
                  
  belongs_to :device
  has_one :program
  
  #scope :without_device, where(:device_id => nil)


  def self.update_job_status
    Device.all.each do |d|
      d.jobs.find(:all, :conditions => ["finished = ?", 0]).each do |j|
        if (j.start.to_datetime + Program.find(j.program_id).duration_in_min.minute) <= DateTime.now &&
            j.confirm == true
          if j.update_attribute('finished', 1)
            puts "Device: #{d.name}, Job_id: #{j.id} wurde auf beendet gesetzt"
          else
            puts "Fehler beim Beenden von Device: #{d.name}, Job_id: #{j.id}"
          end
        end
      end
      if d.jobs.find(:all, :conditions => ["finished == ?", 0]).count == 0
        if d.update_attributes(:state => 0)
          puts "Status von Device: #{d.name} wurde auf 0 gesetzt"
        else
          puts "Fehler beim Status auf 0 setzen von Device: #{d.name}"
        end
      end
    end
  end
  
  def self.shift_jobs
    puts "Start"
    Device.all.each do |d|
      puts "#{d.name}"
      first_job = d.jobs.order("id ASC").limit(1).find(:all, :conditions => ["finished = ?", 0])
      puts "#{d.jobs.order("id ASC").limit(1).find(:all, :conditions => ["finished = ?", 0])}"
      puts "FirstJob: #{first_job[0]}"
      if  first_job[0] != nil && first_job[0].start.to_datetime < DateTime.now &&
          first_job[0].confirm == false
        
        time_difference = ((DateTime.now - first_job[0].start.to_datetime).to_f*24*60).to_i
        puffer = 1
        d.jobs.find(:all, :conditions => ["finished == ?", 0]).each do |j|
          puts "Job: #{j}"
          if j.update_attribute('start', (j.start.to_datetime + time_difference.minute + puffer.minute))
            puts "Device: #{d.name}, Job_id: #{j.id} - Startzeit erhoeht"
          else
            puts "Device: #{d.name}, Job_id: #{j.id} - Fehler: Startzeit sollte um 1 Minute erhoeht werden"
          end
        end
      end
    end
  end
  
  private
  
  def check_end_of_timespans
    return false if end_of_timespan < DateTime.now + (Program.find(device_id).duration_in_min).minute
  end
end
