#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "Failure - Sonnenzeit: Jetzt + 7 Stunden:", :type => :feature do
  before :each do
    Timecop.freeze(DateTime.now)
    user = User.new(  name: "Stephan Brinkmann",
                      email: "sbrink@tzi.de",
                      password: '12345678', 
                      password_confirmation: '12345678',
                      apartmentnumber: 1)
    user.skip_confirmation! 
    user.save!
    
    visit "/users/sign_in"

    fill_in "Email",    :with => "sbrink@tzi.de"
    fill_in "Passwort", :with => "12345678"

    click_button "Anmelden"
    
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 2)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
  
    visit new_device_job_path(Device.find(1))
    select('Pflegeleicht, 40° (180 Minuten)', :from => 'Program')
    #Erster Job
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now,
                end_of_timespan: DateTime.now + 12.hour,
                start: DateTime.now,
                user_id: 1,
                confirm: true,
                is_running: false)
    #zweiter Job
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now,
                end_of_timespan: DateTime.now + 12.hour,
                start: DateTime.now + 7.hour,
                user_id: 1,
                confirm: true,
                is_running: false)
  end

  it "Erster Job: Start - Jetzt, 
      zweiter Job: Start - Sonnenzeit
      neuer Job: Soll in 4 Stunden fertig werden" do
    
    fill_in "Fertig bis spätestens", with: (DateTime.now + 4.hour)
    click_button 'Auftrag erstellen'
    
    current_path.should == device_jobs_path(Device.find(1))
    assert_equal(2, Job.all.count)
  end
end