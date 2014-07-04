# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
 	Timeinterval.create(:time_interval_mins => "5")
 	Timeinterval.create(:time_interval_mins => "10")
 	Timeinterval.create(:time_interval_mins => "20")
 	Timeinterval.create(:time_interval_mins => "30")
 	Radius.create(:radius => "1")
 	Radius.create(:radius => "2")
 	Radius.create(:radius => "3")
 	Radius.create(:radius => "4")
 	Radius.create(:radius => "5")
 	Layout.create(:layouts => "Default")