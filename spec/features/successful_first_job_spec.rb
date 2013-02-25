#!/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe "08Uhr - Erster Job fuer das Device", :type => :feature do
  before :each do
    Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
    Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
    Timecop.freeze(Time.local(2013, 9, 1, 8, 0, 0))
    
    visit new_device_job_path(Device.find(1))
    
    page.should have_content 'Miele Keller 1'
    page.should have_content 'für das Gerät Miele Keller 1'
    assert_equal(0, Device.find(1).state)
    select('Pflegeleicht', :from => 'Program')
    choose('Yes')
  end

  it "Job muss spätestens 11 Uhr fertig sein" do

    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 11, :min => 0, :sec => 0})
    
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    assert_equal(DateTime.now.change({:hour => 8, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    assert_equal(2, Device.find(1).state)
  end
  
  it "Job muss spätestens 18 Uhr fertig sein" do
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 18, :min => 0, :sec => 0}) 
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    
    assert_equal(DateTime.now.change({:hour => 12, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    assert_equal(1, Device.find(1).state)
  end
  
  it "Job muss spätestens 13 Uhr fertig sein" do
    fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 13, :min => 0, :sec => 0})
    click_button 'Auftrag erstellen'
    current_path.should == root_path
    
    assert_equal(DateTime.now.change({:hour => 10, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    assert_equal(1, Device.find(1).state)
  end
end

describe "13Uhr - Erster Job fuer das Device", :type => :feature do
    before :each do
      Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
      Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
      Timecop.freeze(Time.local(2013, 9, 1, 13, 0, 0))
      
      visit new_device_job_path(Device.find(1))
      page.should have_content 'Miele Keller 1'
      page.should have_content 'für das Gerät Miele Keller 1'
      assert_equal(0, Device.find(1).state)
      select('Pflegeleicht', :from => 'Program')
      choose('Yes')
    end

    it "Job muss spätestens 16 Uhr fertig sein" do
      fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 16, :min => 0, :sec => 0})
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      
      assert_equal(2, Device.find(1).state)
      assert_equal(DateTime.now.change({:hour => 13, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    end
end

describe "15Uhr - Erster Job fuer das Device", :type => :feature do
    before :each do
      Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
      Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
      Timecop.freeze(Time.local(2013, 9, 1, 15, 0, 0))
      
      visit new_device_job_path(Device.find(1))
      page.should have_content 'Miele Keller 1'
      page.should have_content 'für das Gerät Miele Keller 1'
      assert_equal(0, Device.find(1).state)
      select('Pflegeleicht', :from => 'Program')
      choose('Yes')
    end

    it "Job muss spätestens 21 Uhr fertig sein" do   
      fill_in "Fertig bis spätestens", with: DateTime.now.change({:hour => 21, :min => 0, :sec => 0})
      click_button 'Auftrag erstellen'
      current_path.should == root_path
      
      assert_equal(2, Device.find(1).state)
      assert_equal(DateTime.now.change({:hour => 15, :min => 0, :sec => 0}), Job.find(1).start.to_datetime)
    end
end

