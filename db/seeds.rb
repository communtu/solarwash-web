# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Device.create(name: "Miele Keller 1", devicetype: 0, state: 0)
Device.create(name: "Miele Keller 2", devicetype: 0, state: 1)
Device.create(name: "Bosch Keller 1", devicetype: 1, state: 0)
Device.create(name: "Bauknecht Keller 2", devicetype: 1, state: 2)
