# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

DeviceType.where(id: 1, name: 'iOS').first_or_create!
DeviceType.where(id: 2, name: 'Android').first_or_create!

tempsalt = BCrypt::Engine.generate_salt
UserAuthentication.where(id: 1, username: 'admin').first_or_create!({:email => 'admin@utecloud.com', :salt => tempsalt, :password => 'admin', :timezone => 'Melbourne'})
