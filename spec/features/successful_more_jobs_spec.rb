#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "Mehrere Jobs vorhanden - Sonnenzeit: Jetzt + 7 Stunden", :type => :feature do
  before :each do
    #TODO : Auslagern
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
    Setting.create(sun_hour: DateTime.now.hour+7, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    
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
      zweiter Job: Start - Sonnenzeit,
      neuer Job: Soll spätestens in 12 Stunden fertig sein" do
    
    fill_in "Fertig bis spätestens", with: (DateTime.now + 12.hour)

    click_button 'Auftrag erstellen'
    current_path.should == root_path
    
    #Erster Job, Start: 5
    assert_equal(DateTime.now, Job.find(1).start.to_datetime)
    #Zweiter Job, Start: 8
    assert_equal(DateTime.now + 3.hour, Job.find(2).start.to_datetime)  
    #Neuer Job, Start: 12
    assert_equal(DateTime.now + 7.hour, Job.find(3).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
  
  it "Erster Job: Start - Jetzt, 
      zweiter Job: Start - Jetzt + 3 Stunden,
      dritter Job: Start - Sonnenzeit
      neuer Job: Soll spätestens in 12,5 Stunden fertig sein" do
    #Zweiter Job:
    Job.find(2).update_attributes(:start => DateTime.now + 3.hour)
    #Dritter Job:
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now,
                end_of_timespan: DateTime.now + 12.hour,
                start: DateTime.now + 7.hour,
                user_id: 1,
                confirm: true,
                is_running: false)


    fill_in "Fertig bis spätestens", with: (DateTime.now + 12.hour + 30.minute)
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 5
    assert_equal(DateTime.now, Job.find(1).start.to_datetime)
    #Zweiter Job, Start: 8
    assert_equal(DateTime.now + 3.hour, Job.find(2).start.to_datetime)
    #Dritter Job, Start: 11
    assert_equal(DateTime.now + 6.hour, Job.find(3).start.to_datetime) 
    #Neuer Job, Start: 14
    assert_equal(DateTime.now + 9.hour, Job.find(4).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
end