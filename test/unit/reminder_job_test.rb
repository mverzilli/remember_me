require 'test_helper'

class ReminderJobTest < ActiveSupport::TestCase
  test "perform" do
    job = ReminderJob.new :text => "hello world!", :to => "sms://1234"
    job.perform
  end
end