module ConfirmHelper
  
  def self.confirm_shift_all_jobs(jobs)
    jobs.each_with_index do |j,index|
      if jobs[index+1] != nil
        time_difference = ((j.start.to_datetime + Program.find(j.program_id).duration_in_min.minute -
                            jobs[index+1].start.to_datetime).to_f*24*60).to_i
        if time_difference > 0
          if jobs[index+1].update_attribute('start', (j.start.to_datetime + Program.find(j.program_id).duration_in_min.minute))
            puts "Job_id: #{jobs[index+1].start} - Startzeit erhoeht"
          else
            puts "Job_id: #{jobs[index+1].id} - Fehler beim erhoehen der Startzeit"
          end
        end
      end
    end
  end
  
  def self.confirm_shift_first_job(first_job)
    time_difference = ((DateTime.now - first_job.start.to_datetime).to_f*24*60).to_i
    puffer = 1
    time_to_shift = puffer + time_difference
    first_job.update_attribute('start', (first_job.start.to_datetime + time_difference.minute + puffer.minute))
  end
  
end
