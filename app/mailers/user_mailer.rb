class UserMailer < ActionMailer::Base
  default from: "solarwash@solarwash.com"
  
  def job_finished_email(user, device, program)
      @user = user
      @url = "http://communtu.de:3020/"
      @device  = device
      @program = program
      mail(:to => user.email, :subject => "Waesche ist fertig")
  end 
  
  def confirm_time_has_expired_mail(user, device, program)
    @user = user
    @url = "http://communtu.de:3020/"
    @device  = device
    @program = program
    mail(:to => user.email, :subject => "Auftrag geloescht")
  end
  
  def confirm_possible(user, device, program, job)
    @user = user
    @url = "http://communtu.de:3020/"
    @device  = device
    @job = job
    @program = program
    mail(:to => user.email, :subject => "Bestaetigung moeglich")
  end
  
  def job_start(user, device, program, job)
    @user = user
    @url = "http://communtu.de:3020/"
    @device  = device
    @job = job
    @program = program
    mail(:to => user.email, :subject => "Auftrag gestartet")    
  end
  
end
