#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "5Uhr:", :type => :feature do
  before :each do
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 2)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    Timecop.freeze(Time.local(2013, 9, 1, 5, 0, 0))
                
    visit new_device_job_path(Device.find(1))
    select('Pflegeleicht', :from => 'Program')
    #Erster Job
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 5, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 17, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 5, :min => 0, :sec => 0 }),
                user_id: nil )
    #Zweiter Job
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 5, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 17, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 12, :min => 0, :sec => 0 }),
                user_id: nil )
  end

  it "Erster Job: Zeitspanne: 5-17 (Start: 5), 
      zweiter Job: Zeitspanne: 5-17 (Start: 12),
      neuer Job: Zeitspanne: 5-17" do
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 17, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 5
    assert_equal(DateTime.now.change({:hour => 5, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Zweiter Job, Start: 8
    assert_equal(DateTime.now.change({:hour => 8, :min => 0, :sec => 0}), Job.find(2).start.to_datetime)  
    #Neuer Job, Start: 12
    assert_equal(DateTime.now.change({:hour => 12, :min => 0, :sec => 0}), Job.find(3).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
  
  it "Erster Job: Zeitspanne: 5-17 (Start: 5), 
      zweiter Job: Zeitspanne: 5-17 (Start: 8),
      dritter Job: Zeitspanne: 5-17 (Start: 12)
      neuer Job: Zeitspanne: 5-17" do
    #Zweiter Job:
    Job.find(2).update_attributes(:start => DateTime.now.change({ :hour => 8, :min => 0, :sec => 0 }))
    #Dritter Job:
    Job.create( device_id: 1, finished: 0, program_id: 1, 
                start_of_timespan: DateTime.now.change({ :hour => 5, :min => 0, :sec => 0 }),
                end_of_timespan: DateTime.now.change({ :hour => 17, :min => 0, :sec => 0 }),
                start: DateTime.now.change({ :hour => 12, :min => 0, :sec => 0 }),
                user_id: nil )   


    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 17, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    #Erster Job, Start: 5
    assert_equal(DateTime.now.change({:hour => 5, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    #Zweiter Job, Start: 8
    assert_equal(DateTime.now.change({:hour => 8, :min => 0, :sec => 0}), Job.find(2).start.to_datetime)
    #Dritter Job, Start: 11
    assert_equal(DateTime.now.change({:hour => 11, :min => 0, :sec => 0}), Job.find(3).start.to_datetime) 
    #Neuer Job, Start: 14
    assert_equal(DateTime.now.change({:hour => 14, :min => 0, :sec => 0}), Job.find(4).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
end