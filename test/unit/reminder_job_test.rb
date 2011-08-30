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
    #setup
    pregnant = pregnant_make
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 1, @messages_sent.size
    message_sent = @messages_sent[0]
    assert_equal message.text, message_sent[:body]
    assert_equal subscriber.phone_number, message_sent[:to]
    assert_equal "sms://remindem", message_sent[:from]
  end
  
  test "messages are not sent when schedule is paused" do
    #setup
    pregnant = pregnant_make
    pregnant.paused = true
    pregnant.save!
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 0, @messages_sent.size
  end
  
  test "messages are not sent when schedule is deleted" do
    #setup
    pregnant = pregnant_make
    subscriber = pregnant.subscribers.find_by_offset(0)
    message = pregnant.messages.first
    pregnant.delete
    
    job = ReminderJob.new(subscriber.id, pregnant.id, message.id)
    job.perform

    assert_equal 0, @messages_sent.size
  end
end