require 'test_helper'

class SubscriberTest < ActiveSupport::TestCase
  test "subscribe" do
    subscribers_count = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant 10"
    
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    
    assert_not_nil created_subscriber
    assert_equal 10, created_subscriber.offset
    assert_not_nil created_subscriber.schedule
    assert_equal schedule, created_subscriber.schedule
    assert_in_delta DateTime.current.utc.to_f, created_subscriber.subscribed_at.to_f, 1.minute.to_f
  end
  
  test "subscribe supports absent offset, defaults to 0" do
    pregnant_schedule = Schedule.find_by_keyword "pregnant"
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant"
    
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
        
    assert_equal 0, created_subscriber.offset
    assert_equal "rememberme".with_protocol, result[0][:from]
    assert_equal pregnant_schedule.welcome_message, result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know there's no schedule with that keyword" do
    subscribers = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "lalala 23"
    
    assert_equal subscribers, Subscriber.count
    assert_equal "rememberme".with_protocol, result[0][:from]
    assert_equal Subscriber.no_schedule_message("lalala"), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know offset has to be a number" do
    subscribers = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant bleh"
    
    assert_equal subscribers, Subscriber.count
    assert_equal "rememberme".with_protocol, result[0][:from]
    assert_equal Subscriber.invalid_offset_message("pregnant bleh", "bleh"), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "validates required fields" do
    subscriber = Subscriber.new 
    subscriber.save
    
    assert subscriber.invalid? 
    assert !subscriber.errors[:phone_number].blank?
    assert !subscriber.errors[:subscribed_at].blank?    
    assert !subscriber.errors[:offset].blank?    
    assert !subscriber.errors[:schedule_id].blank?        
  end
end
