require 'test_helper'

class SubscriberTest < ActiveSupport::TestCase
  test "subscribe" do
    schedule = pregnant_make
    
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => schedule.user.email
    
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    
    assert_not_nil created_subscriber
    assert_equal 10, created_subscriber.offset
    assert_not_nil created_subscriber.schedule
    assert_equal schedule, created_subscriber.schedule
    assert_equal "remindem".with_protocol, result[0][:from]
    assert_equal schedule.welcome_message, result[0][:body]
    assert_in_delta Time.now.utc.to_f, created_subscriber.subscribed_at.to_f, 1.minute.to_f
  end
  
  test "subscribe supports absent offset, defaults to 0" do
    schedule = pregnant_make
    
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant", :'x-remindem-user' => schedule.user.email
    
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    
    assert_equal 0, created_subscriber.offset
    assert_equal "remindem".with_protocol, result[0][:from]
    assert_equal schedule.welcome_message, result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know there's no schedule with that keyword" do
    someAuthor = User.make
    subscribers = Subscriber.count
    
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "lalala 23", :'x-remindem-user' => someAuthor.email
    
    assert_equal subscribers, Subscriber.count
    assert_equal "remindem".with_protocol, result[0][:from]
    assert_equal Subscriber.no_schedule_message("lalala"), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know offset has to be a number" do
    schedule = pregnant_make
    subscribers = Subscriber.count

    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant bleh", :'x-remindem-user' => schedule.user.email
    
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
    
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "#{schedule.keyword} 23", :'x-remindem-user' => otherAuthor.email
    
    assert_equal Subscriber.no_schedule_message(schedule.keyword), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "let the user know the author was not found (usually wrong configuration) if not x-remindem-user" do
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "foo 23"
    
    assert_equal Subscriber.invalid_author('foo'), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end

  test "let the user know the author was not found (usually wrong configuration)" do
    result = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "foo 23", :'x-remindem-user' => 'not-user-email@acme.com'
    
    assert_equal Subscriber.invalid_author('foo'), result[0][:body]
    assert_equal "sms://8558190", result[0][:to]
  end
  
  test "unsubscribe from specific reminder" do
    pregnant_schedule = pregnant_make
    pregnant_schedule.title= 'Pregnancy reminders'
    pregnant_schedule.save!
    randweeks_schedule = randweeks_make
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => pregnant_schedule.user.email
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "randweeks 10", :'x-remindem-user' => randweeks_schedule.user.email
    pregnant_schedule = Schedule.find_by_keyword "pregnant"
    pregnant_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", pregnant_schedule
    assert_not_nil pregnant_subscriber
    randweeks_schedule = Schedule.find_by_keyword "randweeks"
    randweeks_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", randweeks_schedule
    assert_not_nil randweeks_subscriber
    
    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "Stop pregnant", :'x-remindem-user' => pregnant_schedule.user.email
    
    schedule = Schedule.find_by_keyword "pregnant"
    pregnant_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", pregnant_schedule
    assert_nil pregnant_subscriber
    assert_not_nil pregnant_schedule
    randweeks_schedule = Schedule.find_by_keyword "randweeks"
    randweeks_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", randweeks_schedule
    assert_not_nil randweeks_subscriber
    assert_equal [:from=>"sms://remindem",
      :body=> "You have successfully unsubscribed from the \"Pregnancy reminders\" Reminder. To subscribe again send \"pregnant\" to this number",
      :to=>"sms://8558190"], answer
  end
  
  test "sending opt out message without specifying the schedule should answer with the schedules list and a set of instructions to opt out properly" do
    pregnant_schedule = pregnant_make
    randweeks_schedule = randweeks_make
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => pregnant_schedule.user.email
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "randweeks 10", :'x-remindem-user' => randweeks_schedule.user.email
    pregnant_schedule = Schedule.find_by_keyword "pregnant"
    randweeks_schedule = Schedule.find_by_keyword "randweeks"
    created_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", pregnant_schedule
    assert_not_nil created_subscriber
    created_subscriber = Subscriber.find_by_phone_number_and_schedule_id "sms://8558190", randweeks_schedule
    assert_not_nil created_subscriber
    
    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "STOP", :'x-remindem-user' => pregnant_schedule.user.email
    
    created_subscribers = Subscriber.find_all_by_phone_number "sms://8558190"
    assert_not_empty created_subscribers
    assert_equal 2, created_subscribers.size
    assert_equal [:from=>"sms://remindem",
      :body=> "You are subscribed to: [\"pregnant\", \"randweeks\"]. Please specify the reminder you want to unsubscribe: 'off keyword'.",
      :to=>"sms://8558190"], answer
  end
  
  test "unsubscribe from sole reminder" do
    schedule = pregnant_make
    schedule.title= 'Pregnancy reminders'
    schedule.save!
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => schedule.user.email
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_not_nil created_subscriber
    
    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "stop", :'x-remindem-user' => schedule.user.email
    
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_nil created_subscriber
    assert_not_nil schedule
    assert_equal [:from=>"sms://remindem",
      :body=> "You have successfully unsubscribed from the \"Pregnancy reminders\" Reminder. To subscribe again send \"pregnant\" to this number",
      :to=>"sms://8558190"], answer
  end
  
  test "unsubscribe from unsubscribed reminder" do
    schedule = pregnant_make
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_nil created_subscriber
    
    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "StOp pregnant", :'x-remindem-user' => schedule.user.email
    
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_nil created_subscriber
    assert_not_nil schedule
    assert_equal [:from=>"sms://remindem",
      :body=> "Sorry, you are not subscribed to reminder program named pregnant :(.",
      :to=>"sms://8558190"], answer
  end
  
  test "subscribe to an already subscribed schedule should warn you and don't subscribe again" do
    schedule = pregnant_make
    schedule.title= 'Pregnancy reminders'
    schedule.save!
    Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant 10", :'x-remindem-user' => schedule.user.email
    schedule = Schedule.find_by_keyword "pregnant"
    created_subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_not_nil created_subscriber

    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant", :'x-remindem-user' => schedule.user.email

    schedule = Schedule.find_by_keyword "pregnant"
    assert_equal 1, (Subscriber.find_all_by_phone_number "sms://8558190").size
    subscriber = Subscriber.find_by_phone_number "sms://8558190"
    assert_not_nil schedule
    assert_equal [:from=>"sms://remindem",
      :body=> "Sorry, you are already subscribed to reminder program named pregnant. To unsubscribe please send 'stop pregnant'.",
      :to=>"sms://8558190"], answer
  end
  
  test "subscribe to different schedules should not conflict with multiple subscription to the same schedule" do
    pregnant = pregnant_make
    pregnant.title= 'Pregnancy reminders'
    pregnant.save!
    
    randweeks = randweeks_make
    randweeks.title= 'Random tips'
    randweeks.save!
    
    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "pregnant", :'x-remindem-user' => pregnant.user.email
    pregnant = Schedule.find_by_keyword "pregnant"
    assert_equal 1, (Subscriber.find_all_by_phone_number "sms://8558190").size
    assert_equal "sms://remindem", answer[0][:from]
    assert_equal pregnant.welcome_message, answer[0][:body]
    assert_equal "sms://8558190", answer[0][:to]

    answer = Subscriber.modify_subscription_according_to :from => "sms://8558190", :body => "randweeks", :'x-remindem-user' => randweeks.user.email
    randweeks = Schedule.find_by_keyword "randweeks"
    assert_equal 2, (Subscriber.find_all_by_phone_number "sms://8558190").size
    assert_equal "sms://remindem", answer[0][:from]
    assert_equal randweeks.welcome_message, answer[0][:body]
    assert_equal "sms://8558190", answer[0][:to]
  end
end
