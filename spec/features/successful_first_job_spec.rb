#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "Erster Auftrag fuer das Device", :type => :feature do

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
    
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
        
    visit new_device_job_path(Device.find(1))
    
    page.should have_content 'Miele Keller 1'
    page.should have_content 'für das Gerät Miele Keller 1'
    assert_equal(0, Device.find(1).state)
    select('Pflegeleicht, 40° (180 Minuten)', :from => 'Program')
    choose('Yes')
  end

  describe "Sonnenzeit: Jetzt + 4 Stunden - Erster Job fuer das Device:", :type => :feature do
    
    before :each do
      Setting.create(sun_hour: DateTime.now.hour+4, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    end      

    it "Job muss spätestens in 3 Stunden fertig sein" do

      fill_in "Fertig bis spätestens", with: (DateTime.now + 3.hour)
      
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      assert_equal(DateTime.now, Job.find(1).start.to_datetime)
      assert_equal(2, Device.find(1).state)
    end
    
    it "Job muss spätestens in 10 Stunden fertig sein" do
      fill_in "Fertig bis spätestens", with: (DateTime.now + 10.hour) 
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      
      assert_equal(DateTime.now.change({hour: DateTime.now.hour+4, min: DateTime.now.min, sec: DateTime.now.sec}), Job.find(1).start.to_datetime)
      assert_equal(1, Device.find(1).state)
    end
    
    it "Job muss spätestens in 5 Stunden fertig sein" do
      fill_in "Fertig bis spätestens", with: (DateTime.now + 5.hour)
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      
      assert_equal(DateTime.now.change({hour: DateTime.now.hour+2, min: DateTime.now.min, sec: DateTime.now.sec}), Job.find(1).start.to_datetime)
      assert_equal(1, Device.find(1).state)
    end
  end

  describe "Sonnenzeit: Jetzt -1 Stunde - Erster Job fuer das Device:", :type => :feature do
      
      before :each do
        Setting.create(sun_hour: DateTime.now.hour-1, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
      end 

      it "Job muss spätestens in 3 Stunden fertig sein" do
        fill_in "Fertig bis spätestens", with: (DateTime.now + 3.hour)
        click_button 'Auftrag erstellen'
        current_path.should == root_path
        
        assert_equal(2, Device.find(1).state)
        assert_equal(DateTime.now, Job.find(1).start.to_datetime)
      end
  end

  describe "Sonnenzeit: Jetzt -3 Stunden - Erster Job fuer das Device:", :type => :feature do

    before :each do
      Setting.create(sun_hour: DateTime.now.hour-3, sun_minute: DateTime.now.min, sun_second: DateTime.now.sec , time_to_confirm: 5)
    end 

    it "Job muss spätestens in 5 Stunden  Uhr fertig sein" do   
      fill_in "Fertig bis spätestens", with: (DateTime.now + 5.hour)
      click_button 'Auftrag erstellen'
      current_path.should == root_path
        
      assert_equal(2, Device.find(1).state)
      assert_equal(DateTime.now, Job.find(1).start.to_datetime)
    end
  end

end