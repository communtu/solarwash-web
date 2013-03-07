#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "Ein Job vorhanden:", :type => :feature do
  before :each do
    Timecop.freeze(DateTime.now)
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

    Device.create(name: "Miele Keller 1", devicetype: 0, state: 1)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)

    visit new_device_job_path(Device.find(1))

    page.should have_content 'Miele Keller 1'
    page.should have_content 'für das Gerät Miele Keller 1'
    select('Pflegeleicht, 40° (180 Minuten)', :from => 'Program')
    
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now,
                end_of_timespan: DateTime.now + 8.hour,
                start: DateTime.now + 4.hour,
                user_id: 1,
                confirm: true,
                is_running: false)
  end
  
  describe "Sonnenzeit: Jetzt + 4 Stunden", :type => :feature do
    before :each do
      Setting.create(sun_hour: DateTime.now.hour+4, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    end

    it "Erster Job: Wäsche ist in der Waschmaschine \n Neuer Job: Fertig in spätestens 8 Stunden" do
      
      fill_in "Fertig bis spätestens", with: (DateTime.now + 8.hour)
    
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      #Erster Job, Start: Jetzt
      assert_equal(DateTime.now, Job.find(1).start.to_datetime)
      #Neuer Job, Start: Jetzt + 4 Stunden
      assert_equal(DateTime.now + 4.hour, Job.find(2).start.to_datetime)
      assert_equal(2, Device.find(1).state)
    end
  
    it "Neuer Job: Fertig in spätestens 6,5 Stunden" do
      fill_in "Fertig bis spätestens", with: (DateTime.now + 6.hour + 30.minute)
    
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      #Erster Job, Start: Jetzt
      assert_equal(DateTime.now, Job.find(1).start.to_datetime)
      #Neuer Job, Start: 30 Minuten vor der Sonnenzeit
      assert_equal(DateTime.now + 3.hour + 30.minute, Job.find(2).start.to_datetime)
      assert_equal(2, Device.find(1).state)
    end
  end

  describe "Sonnenzeit: Jetzt + 2 Stunden:", :type => :feature do
    before :each do
      Setting.create(sun_hour: DateTime.now.hour+2, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    end
    
    it "Neuer Job: Fertig in spätestens 6,5 Stunden" do
      Job.find(1).update_attributes(start: DateTime.now + 2.hour)
      
      fill_in "Fertig bis spätestens", with: (DateTime.now + 6.hour + 30.minute)
    
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      #Erster Job, Start: Jetzt
      assert_equal(DateTime.now, Job.find(1).start.to_datetime)
      #Neuer Job, Start: In 3 Stunden
      assert_equal(DateTime.now + 3.hour, Job.find(2).start.to_datetime)
      assert_equal(2, Device.find(1).state)
    end
  end

  describe "Sonnenzeit: Jetzt - 3 Stunden:", :type => :feature do
    before :each do
      Setting.create(sun_hour: DateTime.now.hour-3, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    end
  
    it "Erster Job läuft seit einr Stunde, Neuer Job: Fertig in spätestens 6,5 Stunden" do
      Job.find(1).update_attributes(start: DateTime.now - 1.hour)
      Device.find(1).update_attributes(:state => 2)

      fill_in "Fertig bis spätestens", with: (DateTime.now + 6.hour + 30.minute)
    
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      #Erster Job, Start: Vor einer Stunde
      assert_equal(DateTime.now - 1.hour, Job.find(1).start.to_datetime)
      #Neuer Job, Start: In zwei Stunden
      assert_equal(DateTime.now + 2.hour, Job.find(2).start.to_datetime)
      assert_equal(2, Device.find(1).state)
    end
  end
end