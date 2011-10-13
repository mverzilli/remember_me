require 'test_helper'

class RandomScheduleTest < ActiveSupport::TestCase
  def setup
    set_current_time
        
    @schedule = RandomSchedule.make :timescale => 'day'
    @phone_1 = 'sms://4001'
  end
  
  def teardown
    Time.unstub(:now)
  end
    
  def subscribe(phone, offset = nil)
    Subscriber.modify_subscription_according_to :from => phone, :body => "#{@schedule.keyword} #{offset}", :'x-remindem-user' => @schedule.user.email
    # reloads schedule of each message
    @schedule.messages.each do |m|
      m.schedule(true)
    end
  end
  
  def create_message(attributes)
    @schedule.messages.create! attributes
  end
  
  test "subscribers should receive messages at subscription time" do
    create_message :text => 'a'
    create_message :text => 'b'
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 1.hour
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    time_advance 12.hours
    assert_no_message_sent @phone_1
    
    time_advance 12.hours
    assert_message_sent @phone_1, /a|b/
  end
  
  test "subscribers should not receive messages far away of subscription time" do
    create_message :text => 'a'
    create_message :text => 'b'
    
    time_advance 2.hours
    subscribe @phone_1
    
    time_advance 1.hour
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    time_advance 12.hours
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1
    
    time_advance 12.hours
    assert_message_sent @phone_1, /a|b/    
  end
  
  test "messages should not be sent if schedule is paused" do
    create_message :text => 'a'
    create_message :text => 'b'
  
    subscribe @phone_1  
    time_advance 1.hour
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    time_advance 12.hours
    @schedule.paused = true
    @schedule.save!

    time_advance 12.hours
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1
        
    time_advance 1.day
    assert_no_message_sent @phone_1
  end
  
  test "subscribers should receive updated text" do
    @message1 = create_message :text => 'a'
    @message2 = create_message :text => 'b'
  
    subscribe @phone_1
    time_advance 1.hour
    
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    # unable to know which is pending, so we change both
    @message1.update_attributes :text => 'c'
    @message2.update_attributes :text => 'c'
    
    time_advance 1.day
    assert_message_sent @phone_1, 'c'
  end
  
  test "subscribers should not receive deleted messages" do
    @message1 = create_message :text => 'a'
    @message2 = create_message :text => 'b'
    
    subscribe @phone_1
    time_advance 1.hour
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    time_advance 12.hours
    @message1.destroy
    @message2.destroy

    time_advance 12.hours
    assert_no_message_sent @phone_1
  end

  test "subscribers should receive created messages after subscription" do
    create_message :text => 'a'
    create_message :text => 'a'
    
    subscribe @phone_1
    time_advance 1.hour
    assert_message_sent @phone_1, 'a'
    clear_messages
    
    time_advance 12.hours
    create_message :text => 'b'
    time_advance 12.hours
    assert_message_sent @phone_1, /a|b/
    clear_messages
    
    time_advance 1.day
    assert_message_sent @phone_1, /a|b/
  end
  
  test "subscribers should receive created messages after subscription even no more messages are pending" do
    create_message :text => 'a'
    create_message :text => 'a'
    
    subscribe @phone_1
    time_advance 1.hour
    assert_message_sent @phone_1, 'a'
    clear_messages

    time_advance 1.day
    assert_message_sent @phone_1, 'a'
    clear_messages
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 8.hours
    create_message :text => 'b'
    assert_no_message_sent @phone_1
        
    time_advance 8.hours
    assert_no_message_sent @phone_1

    time_advance 8.hours
    assert_message_sent @phone_1, 'b'
    clear_messages
  end
  
  test "blanks should be filled with other messages" do    
    @message1 = create_message :text => 'a'
    @message2 = create_message :text => 'a'
    
    subscribe @phone_1
    @schedule.subscribers.reload
    time_advance 1.hour
    assert_message_sent @phone_1, 'a'
    clear_messages
    
    create_message :text => 'b'
    time_advance 8.hours
    assert_no_message_sent @phone_1
    
    #this message is (probably) enqueued to the end of all messages
    #when removeing olders
    @message1.destroy
    @message2.destroy
    # the new one should be received by phone_1 in 16 hours
    time_advance 8.hours
    assert_no_message_sent @phone_1

    time_advance 8.hours
    assert_message_sent @phone_1, 'b'
  end
  
  test "reminder duration" do
    schedule = randweeks_make
    assert_equal 5, schedule.duration

    schedule.messages.create! :text => 'ble'
    schedule.messages.create! :text => 'ble'
    
    assert_equal 7, schedule.duration
  end
  
end