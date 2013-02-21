# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Geräte
Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
Device.create(name: "Miele Keller 2", devicetype: 0, state: 1)
Device.create(name: "Bosch Keller 1", devicetype: 1, state: 0)
Device.create(name: "Bauknecht Keller 2", devicetype: 1, state: 2)

#:consumption_in_wh, :degree, :duration_in_min, :name
Program.create(name: "Pflegeleicht", degree: "40", duration_in_min: 110, consumption_in_wh: 560)

#attr_accessible :device_id, :end_of_timespan, :finished, :program_id, :start_of_timespan, :user_id
Job.create( device_id: 1,
            program_id: 1,
            user_id: 1,
            start_of_timespan: DateTime.now()-2,
            end_of_timespan: DateTime.now()-1,
            finished: 0)
            
Job.create( device_id: 1,
            program_id: 1,
            user_id: 1,
            start_of_timespan: DateTime.now(),
            end_of_timespan: DateTime.now()+1,
            finished: 0)
            
Job.create( device_id: 3,
            program_id: 1,
            user_id: 1,
            start_of_timespan: DateTime.now(),
            end_of_timespan: DateTime.now()+1,
            finished: 0)
>>>>>>> 02d536787ed9a084f6138631a1f95945a5073d36
