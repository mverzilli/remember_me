require 'test_helper'

class SubscriberTest < ActiveSupport::TestCase
  test "subscribe" do
    schedule = pregnant_make
    
    subscribers_count = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => schedule.user.email
    
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    
    assert_not_nil created_subscriber
    assert_equal 10, created_subscriber.offset
    assert_not_nil created_subscriber.schedule
    assert_equal schedule, created_subscriber.schedule
    assert_in_delta Time.now.utc.to_f, created_subscriber.subscribed_at.to_f, 1.minute.to_f
  end
  
  test "subscribe supports absent offset, defaults to 0" do
    schedule = pregnant_make
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant", :'x-remindem-user' => schedule.user.email
    
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
        
    assert_equal 0, created_subscriber.offset
    assert_equal "remindem".with_protocol, result[0][:from]
    assert_equal schedule.welcome_message, result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know there's no schedule with that keyword" do
    someAuthor = User.make
    subscribers = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "lalala 23", :'x-remindem-user' => someAuthor.email
    
    assert_equal subscribers, Subscriber.count
    assert_equal "remindem".with_protocol, result[0][:from]
    assert_equal Subscriber.no_schedule_message("lalala"), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know offset has to be a number" do
    schedule = pregnant_make
    
    subscribers = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "pregnant bleh", :'x-remindem-user' => schedule.user.email
    
    assert_equal subscribers, Subscriber.count
    assert_equal "remindem".with_protocol, result[0][:from]
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
  
  test "lookup keyword inside author schedules" do
    otherAuthor = User.make
    schedule = FixedSchedule.make
    
    subscribers = Subscriber.count
    
    result = Subscriber.subscribe :from => "sms://8558190", :body => "#{schedule.keyword} 23", :'x-remindem-user' => otherAuthor.email
    
    assert_equal Subscriber.no_schedule_message(schedule.keyword), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know the author was not found (usually wrong configuration) if not x-remindem-user" do
    result = Subscriber.subscribe :from => "sms://8558190", :body => "foo 23"
    
    assert_equal Subscriber.invalid_author('foo'), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end

  test "let the user know the author was not found (usually wrong configuration)" do
    result = Subscriber.subscribe :from => "sms://8558190", :body => "foo 23", :'x-remindem-user' => 'not-user-email@acme.com'
    
    assert_equal Subscriber.invalid_author('foo'), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
end
