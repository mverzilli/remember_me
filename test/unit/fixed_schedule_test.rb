require 'test_helper'

class FixedScheduleTest < ActiveSupport::TestCase
  def setup
    set_current_time
        
    @schedule = FixedSchedule.make :timescale => 'day'
    @phone_1 = 'sms://4001'
  end
  
  def teardown
    Time.unstub(:now)
  end
    
  def subscribe(phone, offset = nil)
    Subscriber.subscribe :from => phone, :body => "#{@schedule.keyword} #{offset}", :'x-remindem-user' => @schedule.user.email
  end
  
  test "subscribers should receive messages at subscription time" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 23.hours
    assert_no_message_sent @phone_1

    time_advance 2.hours
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end

  test "subscribers should not receive messages far away of subscription time" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 23.hours
    assert_no_message_sent @phone_1

    time_advance 2.hours
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    # system is 3 hours from subscription time
    time_advance 2.hours
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1

    # no matter job are pending, they should not be sent
    time_advance 1.day
    assert_no_message_sent @phone_1
    
    # until we reach near the time window.
    # in this example, exactly the subscription time
    time_advance 21.hours
    assert_message_sent @phone_1, 'text at 3'
  end
  
  test "message delivery time should use subscribers offset" do
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1, 1
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end

  test "messages should not be sent if schedule is paused" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
  
    subscribe @phone_1
    time_advance 20.hours
    assert_no_message_sent @phone_1
    
    @schedule.paused = true
    @schedule.save!
    
    time_advance 5.hours
    assert_no_message_sent @phone_1
  end
  
  test "subscribers should receive updated text" do
    @message1 = @schedule.messages.create! :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 20.hours
    
    @message1.update_attributes! :text => 'text at 1 updated'
    
    time_advance 5.hours
    assert_message_sent @phone_1, 'text at 1 updated'
  end
  
  test "subscribers should not receive deleted messages" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    @message3 = @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    @message3.delete
    
    time_advance 1.day
    assert_no_message_sent @phone_1
  end

  test "subscribers should receive created messages after subscription" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end
  
  test "subscribers should not receive created messages after subscription when they have pass that time" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 4.day
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    time_advance 1.day
    assert_no_message_sent @phone_1
  end
  
  test "subscribers should receive later the messages when they are pushed back" do
    @schedule.messages.create! :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 22.hours
    
    @schedule.messages.first.update_attributes :offset => 3
    time_advance 3.hours
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
  end

  test "subscribers should receive earlier the messages when they are brought forward" do
    @schedule.messages.create! :text => 'text at 3', :offset => 3
    
    subscribe @phone_1
    time_advance 22.hours
    
    @schedule.messages.first.update_attributes :offset => 2
    time_advance 3.hours
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end
end