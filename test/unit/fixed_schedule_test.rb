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
    create_message :text => 'text at 1', :offset => 1
    create_message :text => 'text at 3', :offset => 3
    
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
    create_message :text => 'text at 1', :offset => 1
    create_message :text => 'text at 3', :offset => 3
    
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
    create_message :text => 'text at 3', :offset => 3
    
    time_advance 2.hours
    subscribe @phone_1, 1
    
    time_advance 1.day
    assert_no_message_sent @phone_1

    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end

  test "messages should not be sent if schedule is paused" do
    create_message :text => 'text at 1', :offset => 1
  
    subscribe @phone_1
    time_advance 20.hours
    assert_no_message_sent @phone_1
    
    @schedule.paused = true
    @schedule.save!
    
    time_advance 5.hours
    assert_no_message_sent @phone_1
  end
  
  test "subscribers should receive updated text" do
    @message1 = create_message :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 20.hours
    
    @message1.update_attributes! :text => 'text at 1 updated'
    
    time_advance 5.hours
    assert_message_sent @phone_1, 'text at 1 updated'
  end
  
  test "subscribers should not receive deleted messages" do
    create_message :text => 'text at 1', :offset => 1
    @message3 = create_message :text => 'text at 3', :offset => 3
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    @message3.destroy
    
    time_advance 1.day
    assert_no_message_sent @phone_1
  end

  test "subscribers should receive created messages after subscription" do
    create_message :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 1.day
    create_message :text => 'text at 3', :offset => 3
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end
  
  test "subscribers should not receive created messages after subscription when they have pass that time" do
    create_message :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 1.hour
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 1'
    clear_messages
    
    time_advance 4.day
    create_message :text => 'text at 3', :offset => 3
    
    time_advance 1.day
    assert_no_message_sent @phone_1
  end
  
  test "subscribers should receive later the messages when they are pushed back" do
    create_message :text => 'text at 1', :offset => 1
    
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
    create_message :text => 'text at 3', :offset => 3
    
    subscribe @phone_1
    time_advance 22.hours
    
    @schedule.messages.first.update_attributes :offset => 2
    time_advance 3.hours
    assert_no_message_sent @phone_1
    
    time_advance 1.day
    assert_message_sent @phone_1, 'text at 3'
  end
  
  test "when messages are not sent due to paused, log warning" do
    create_message :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 13.hours
    
    @schedule.update_attributes :paused => true
    time_advance 12.hours
    
    assert_no_message_sent @phone_1
    assert_not_nil Log.find_by_schedule_id_and_severity_and_description(@schedule.id, :warning, "The message 'text at 1' was not sent to 4001 since schedule is paused")
  end

  test "when messages are not sent due to timewindow, log warning" do
    create_message :text => 'text at 1', :offset => 1
    
    subscribe @phone_1
    time_advance 13.hours
    time_advance 1.day    
    
    assert_no_message_sent @phone_1
    assert_not_nil Log.find_by_schedule_id_and_severity_and_description(@schedule.id, :warning, "The message 'text at 1' was delayed due to 4001 localtime")
  end
  
  test "reminder duration" do
    schedule = pregnant_make
    assert_equal 36, schedule.duration
    
    schedule.messages.create! :text => 'ble', :offset => 60
    assert_equal 60, schedule.duration
  end
  
end