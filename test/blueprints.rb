require 'machinist/active_record'
require 'sham'
require 'ffaker'

Sham.email { Faker::Internet.email }
Sham.password { ActiveSupport::SecureRandom.base64(6) }
Sham.keyword { Faker::Internet.user_name }
Sham.phone_number { rand(36**8).to_s.with_protocol }
Sham.body { "Message" + rand(265**1).to_s }

User.blueprint do
  email
  password
end

Schedule.blueprint do
  user
  paused { false }
  keyword
  welcome_message { Faker::Lorem.sentence }
  timescale { Schedule.time_scales[rand(Schedule.time_scales.count)] }
end

FixedSchedule.blueprint do
end

RandomSchedule.blueprint do
end

Subscriber.blueprint do
  phone_number
  subscribed_at { DateTime.now.utc }
  offset { 0 }
end

#Message.blueprint do
 # text { Faker::Lorem.sentence }
  #offset { 0 }
  #schedule_id { 1 }
  #created_at { DateTime.now.utc }
  #updated_at { DateTime.now.utc }
#end
  
