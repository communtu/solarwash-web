# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Geräte
Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
Device.create(name: "Miele Keller 2", devicetype: 0, state: 0)
Device.create(name: "Bosch Keller 1", devicetype: 1, state: 0)
Device.create(name: "Bauknecht Keller 2", devicetype: 1, state: 0)

#:consumption_in_wh, :degree, :duration_in_min, :name
Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 1)
Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 2)
Program.create(name: "Trocknervorgang-Normal", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 3)
Program.create(name: "Trocknervorgang-Normal", degree: "40", duration_in_min: 180, consumption_in_wh: 560, device_id: 4)

# Nutzer
User.create!(email: "sbrink@tzi.de", :password => '12345678')
User.create!(email: "eikebehr@tzi.de", :password => 'ddofd666')

#attr_accessible :device_id, :end_of_timespan, :finished, :program_id, :start_of_timespan, :user_id
