require 'test_helper'

class ReminderJobTest < ActiveSupport::TestCase

  def setup
    Nuntium.expects(:new_from_config).returns(self).at_most_once()
    @messages_sent = []
  end

  def teardown
    Nuntium.unstub(:find)
  end

  def send_ao (message)
    @messages_sent << message
  end

  test "message is sent on perform" do
    message_to = "sms://1234"
    schedule = FixedSchedule.new
    schedule.id = 1
    schedule.user = User.find(1)
    newMessage = Message.new
    newMessage.id = 2
    
    job = ReminderJob.new(message_to, schedule.id, newMessage.id)
    job.perform

    assert_equal 1, @messages_sent.size
    message = @messages_sent[0]
    body = Message.find(newMessage.id).text
    assert_equal body, message[:body]
    assert_equal message_to, message[:to]
    assert_equal "sms://remindem", message[:from]
  end
  
  test "messages are not sent when schedule is paused" do
    schedule = FixedSchedule.make :paused => true
    message_body = "hello world!"
    message_to = "sms://1234"
    
    job = ReminderJob.new(message_body, message_to, schedule.id)
    job.perform

    assert_equal 0, @messages_sent.size
  end
  
  test "messages are not sent when schedule is deleted" do
    message_body = "hello world!"
    message_to = "sms://1234"
    
    job = ReminderJob.new(message_body, message_to, 5)
    job.perform

    assert_equal 0, @messages_sent.size
  end
end