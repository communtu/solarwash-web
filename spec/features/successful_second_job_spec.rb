#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "8Uhr-Ein Job vorhanden:", :type => :feature do
  before :each do
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 1)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    Timecop.freeze(Time.local(2013, 9, 1, 8, 0, 0))
                
    visit new_device_job_path(Device.find(1))
    select('Pflegeleicht', :from => 'Program')
  end

  it "Erster Job: Zeitspanne: 8-16 (Start: 12), neuer Job: Zeitspanne: 8-16" do
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 8, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 16, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 12, :min => 0, :sec => 0 }),
                user_id: nil )
    Device.find(1).update_attributes(:state => 1)
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 16, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 8
    assert_equal(DateTime.now.change({:hour => 8, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Neuer Job, Start: 12
    assert_equal(DateTime.now.change({:hour => 12, :min => 0, :sec => 0}), Job.find(2).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
  
  it "Erster Job: Zeitspanne: 8-16 (Start: 12), neuer Job: Zeitspanne: 8-14:30" do
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 8, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 16, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 12, :min => 0, :sec => 0 }),
                user_id: nil )
    Device.find(1).update_attributes(:state => 1)
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 14, :min => 30, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 8
    assert_equal(DateTime.now.change({:hour => 8, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Neuer Job, Start: 11:30
    assert_equal(DateTime.now.change({:hour => 11, :min => 30, :sec => 0}), Job.find(2).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
end

describe "10Uhr-Ein Job vorhanden:", :type => :feature do
  before :each do
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    Timecop.freeze(Time.local(2013, 9, 1, 10, 0, 0))
                
    visit new_device_job_path(Device.find(1))
    select('Pflegeleicht', :from => 'Program')
  end
  
  it "Erster Job: Zeitspanne: 10-16 (Start: 12), neuer Job: Zeitspanne: 10-16:00" do
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 8, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 16, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 12, :min => 0, :sec => 0 }),
                user_id: nil )
    Device.find(1).update_attributes(:state => 1)
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 16, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 10
    assert_equal(DateTime.now.change({:hour => 10, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Neuer Job, Start: 13
    assert_equal(DateTime.now.change({:hour => 13, :min => 0, :sec => 0}), Job.find(2).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
end

describe "15Uhr-Ein Job vorhanden:", :type => :feature do
  before :each do
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    Timecop.freeze(Time.local(2013, 9, 1, 15, 0, 0))
                
    visit new_device_job_path(Device.find(1))
    select('Pflegeleicht', :from => 'Program')
  end
  
  it "Erster Job: Zeitspanne: 14-17 (Start: 14), neuer Job: Zeitspanne: 15-22" do
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 8, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 17, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 14, :min => 0, :sec => 0 }),
                user_id: nil )
    Device.find(1).update_attributes(:state => 2)
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 22, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 14
    assert_equal(DateTime.now.change({:hour => 14, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Neuer Job, Start: 17
  
    assert_equal(DateTime.now.change({:hour => 17, :min => 0, :sec => 0}), Job.find(2).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
end