# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Geräte
Device.create(name: "Miele W6000", devicetype: 0, state: 0)
Device.create(name: "Miele T8861", devicetype: 1, state: 0)
Device.create(name: "Bauknecht RuckzuckTrocken", devicetype: 1, state: 0)

#:consumption_in_wh, :degree, :duration_in_min, :name
Program.create(name: "Baumwolle", degree: "40", duration_in_min: 7, consumption_in_wh: 560, device_id: 1)
Program.create(name: "Automatic Plus", degree: "60", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
Program.create(name: "Oberhemden", degree: "50", duration_in_min: 120, consumption_in_wh: 560, device_id: 1)
Program.create(name: "Schranktrocken", degree: "", duration_in_min: 5, consumption_in_wh: 560, device_id: 2)
Program.create(name: "Baumwolle Hygiene", degree: "", duration_in_min: 75, consumption_in_wh: 560, device_id: 2)
Program.create(name: "Wolle", degree: "", duration_in_min: 180, consumption_in_wh: 560, device_id: 3)
Program.create(name: "Schonen Plus", degree: "", duration_in_min: 60, consumption_in_wh: 560, device_id: 3)

# Nutzer
user = User.new(name: "Stephan Brinkmann", email: "sbrink@tzi.de", :password => '12345678', :password_confirmation => '12345678', apartmentnumber:1)
user.skip_confirmation! 
user.save!

user = User.new(name: "Eike Behrends", email: "eikebehr@tzi.de", :password => 'ddofd666', :password_confirmation => 'ddofd666', apartmentnumber:2)
user.skip_confirmation! 
user.save! 

user = User.new(name: "Solarwash", email: "solarwash@solarwash.de", :password => '12345678', :password_confirmation => '12345678', apartmentnumber:3)
user.skip_confirmation!
user.save!

user = User.new(name: "Admin", email: "admin@solarwash.de", :password => '12345678', :password_confirmation => '12345678', apartmentnumber:4, :admin => true)
user.skip_confirmation!
user.save!

Setting.create(sun_hour: 18, sun_minute: 0, sun_second:0 , time_to_confirm: 3)
#attr_accessible :device_id, :end_of_timespan, :finished, :program_id, :start_of_timespan, :user_id

