require 'machinist/active_record'
require 'sham'
require 'ffaker'

Sham.email { Faker::Internet.email }
Sham.password { ActiveSupport::SecureRandom.base64(6) }
Sham.keyword { Faker::Internet.user_name }
Sham.phone_number { rand(36**8).to_s.with_protocol }
Sham.body { "Message" + rand(265**1).to_s }
Sham.severity { [:information, :error, :warning].pick }
Sham.description { Faker::Lorem.sentence }
Sham.title { Faker::Lorem.words(2) }

Log.blueprint do
  severity
  description
  schedule { [RandomSchedule, FixedSchedule, CalendarBasedSchedule].pick.make }
end

User.blueprint do
  email
  password
end

Schedule.blueprint do
  user
  title
  paused { false }
  keyword
  welcome_message { Faker::Lorem.sentence }
end

FixedSchedule.blueprint do
  timescale { Schedule.time_scales[rand(Schedule.time_scales.count)] }
end

RandomSchedule.blueprint do
  timescale { Schedule.time_scales[rand(Schedule.time_scales.count)] }
end

CalendarBasedSchedule.blueprint do
end

Subscriber.blueprint do
  phone_number
  subscribed_at { DateTime.now.utc }
  offset { 0 }
end
