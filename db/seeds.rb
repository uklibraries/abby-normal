# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[
  'ready', 
  'started', 
  'failed', 
  'completed', 
  'archived', 
  'not ready',
  'approved',
  'rejected',
  'awaiting approval',
  'under review',
].each do |status|
  Status.create(name: status)
end

[
  # pre-approval
  'Get Identifiers',
  'Pull SIP',
  'Create AIP',
  'Create DIP',
  'Store Test DIP',
  'Store Test Oral History Files',
  'Create Solr JSON',
  'Index into Test Solr',

  # approval
  'Approve Package',

  #post-approval
  'Store DIP',
  'Store Oral History Files',
  'Store Solr JSON',
  'Index into Solr',
  'Store AIP',
  'Store Logs',
  'Delete SIP Cache',
  'Delete AIP Cache',
  'Delete DIP Cache',
  'Delete Solr JSON Cache',
  'Delete Log Cache',
  'Archive Package',
].each do |type|
  Type.create(name: type)
end

[
  'free-form',
  'newspapers',
  'EAD',
  'ndnp',
  'oral history',
].each do |batch_type|
  BatchType.create(name: batch_type)
end

[
  'hypnos',
  'moros',
  'nemesis',
].each do |server|
  Server.create(name: server)
end
