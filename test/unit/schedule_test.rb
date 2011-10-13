require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  
  test "validate presence of required fields in schedule" do
    schedule = Schedule.new
    schedule.save
    
    assert schedule.invalid?
    assert !schedule.errors[:keyword].blank?, "Keyword must be present for all Schedules"
    assert !schedule.errors[:user_id].blank?, "User ID must be present for all Schedules"
    assert !schedule.errors[:welcome_message].blank?, "Welcome Message must be present for all Schedules"
    assert !schedule.errors[:type].blank?, "Type must be present for all Schedules"
    assert !schedule.errors[:title].blank?, "Type must be present for all Schedules"
  end
  
  [FixedSchedule, RandomSchedule].each do |klass|
    test "validate presence of required fields in #{klass}" do
      schedule = klass.new
      schedule.save
    
      assert schedule.invalid?
      assert !schedule.errors[:timescale].blank?, "Timescale must be present for #{klass}"
      assert_equal klass.to_s, schedule.type
    end
  
    test "validate lenght of keyword in #{klass}" do
      schedule = klass.new :keyword => ('*' * 16)
      schedule.save
    
      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "Keyword must be smaller than 15 characters"
      
      schedule = klass.make :keyword => ('*' * 15)
      schedule.save!
    end
    
    test "validate lenght of title in #{klass}" do
      schedule = klass.new :title => '*' * 61
      schedule.save
    
      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "Keyword must be smaller than 15 characters"
      schedule = klass.make :title => '*' * 60
      schedule.save!
    end
  end
  
  test "validate uniqueness of keyword" do
    schedule1 = RandomSchedule.create! :keyword => "schedule", :timescale => "weeks", :user_id => 1, :welcome_message => "foo", :title => "bar"
    schedule2 = Schedule.new :keyword => "schedule"
    schedule2.save
    
    assert schedule2.invalid?
    assert !schedule2.errors[:keyword].blank?
  end
  
  test "generate random reminders" do
    randweeks = randweeks_make
    subscriber = Subscriber.make :schedule => randweeks
    
    randweeks.generate_reminders_for subscriber

    messages = randweeks.messages
    sent_at = (1..5).map { |i| subscriber.subscribed_at + i.send(randweeks.timescale.to_sym) }
    
    assert_equal 5, Delayed::Job.count
    
    Delayed::Job.all.each do |job|
      reminder_job = YAML.load(job.handler)
      
      assert_equal 1, messages.select {|msg| msg.text == Message.find(reminder_job.message_id).text}.length
      assert_equal 1, (0..4).select {|i| (job.run_at.to_f - (subscriber.subscribed_at + i.weeks).to_f).abs <= 1.minute.to_f }.length
    end
  end

  test "generate fixed reminders" do
    pregnant = pregnant_make
    subscriber = Subscriber.make :schedule => pregnant

    pregnant.generate_reminders_for subscriber

    messages = pregnant.messages

    assert_equal 5, Delayed::Job.count
    
    Delayed::Job.order(:run_at).each_with_index do |job, index|
      reminder_job = YAML.load(job.handler)
      
      assert_equal messages[index].text, Message.find(reminder_job.message_id).text
      assert job.run_at.to_f - (subscriber.subscribed_at + messages[index].offset.weeks).to_f.abs <= 1.minute.to_f
    end
  end

  test "users are notified when schedule is destroyed" do
    pregnant = FixedSchedule.make :keyword => 'pregnant'
    first_subscriber = Subscriber.make :schedule => pregnant
    second_subscriber = Subscriber.make :schedule => pregnant
    
    #by default, unless otherwise changed by the UI, all users are notified of sched. deletion
    pregnant.destroy

    message_body = "The schedule pregnant has been deleted. You will no longer receive messages from this schedule."

    assert_equal 2, @messages_sent.size

    first_message = @messages_sent[0]
    second_message = @messages_sent[1]

    assert_equal message_body, first_message[:body]
    assert_equal first_subscriber.phone_number, first_message[:to]
    assert_equal "sms://remindem", first_message[:from]

    assert_equal message_body, second_message[:body]
    assert_equal second_subscriber.phone_number, second_message[:to]
    assert_equal "sms://remindem", second_message[:from]
  end
  
  test "users are NOT notified when schedule is destroyed" do
    pregnant = FixedSchedule.make :keyword => 'pregnant'
    first_subscriber = Subscriber.make :schedule => pregnant
    second_subscriber = Subscriber.make :schedule => pregnant

    #the following line simulates a UI-originated preference to NOT send messages to subscribers
    pregnant.notifySubscribers = false
    
    pregnant.destroy

    assert_equal 0, @messages_sent.size
  end

  [FixedSchedule, RandomSchedule].each do |klass| #toDo: Add CalendarBasedSchedule to this list of tests

    test "event is logged when subscriber is added to #{klass}" do
    
      pregnant = klass.make :keyword => 'pregnant'
    
      subscriber = Subscriber.make :schedule => pregnant, :phone_number => 'sms://1234'

      pregnant.subscribe subscriber

      assert_equal 1, Log.count

      log = Log.first
    
      assert_equal :information, log.severity
      assert_equal "New subscriber: 1234", log.description
      assert_equal pregnant, log.schedule
    end
  
    test "event is logged when message is sent on #{klass}" do
    
      pregnant = klass.make
      pregnant.messages.create! :text => 'pregnant1', :offset => 0
      subscriber = Subscriber.make :schedule => pregnant, :phone_number => 'sms://1234'

      pregnant.subscribe subscriber

      assert_equal 2, Log.count
      assert_equal 1, Delayed::Job.count
    
      job = Delayed::Job.first
      scheduled_job = YAML.load(job.handler)
    
      scheduled_job.perform
      assert_equal 3, Log.count
    
      log = Log.last
    
      assert_equal :information, log.severity
      assert_equal "The message 'pregnant1' was sent to 1234", log.description
      assert_equal pregnant, log.schedule
    end

    test "event is logged when message is added updated or removed to #{klass}" do
      
      pregnant = klass.make
      pregnant.messages.create! :text => 'pregnant1', :offset => 0

      assert_equal 1, Log.count
      log = Log.last
      assert_equal :information, log.severity
      assert_equal "Message created: pregnant1", log.description
      assert_equal pregnant, log.schedule
      
      message = pregnant.messages.first
      message.text= 'pregnant2'
      message.save!
      
      assert_equal 2, Log.count
      log = Log.last
      assert_equal :information, log.severity
      assert_equal "Message updated: pregnant2", log.description
      assert_equal pregnant, log.schedule
      
      message = pregnant.messages.first
      message.destroy
      
      assert_equal 3, Log.count
      log = Log.last
      assert_equal :information, log.severity
      assert_equal "Message deleted: pregnant2", log.description
      assert_equal pregnant, log.schedule
    end
    
    test "event is logged when #{klass} is paused or resumed" do
      schedule = klass.make
      assert_equal 0, Log.count
      
      schedule.paused= true
      schedule.save!
      
      assert_equal 1, Log.count
      log = Log.last
      assert_equal :information, log.severity
      assert_equal "Schedule paused", log.description
      assert_equal schedule, log.schedule
      
      schedule.paused= false
      schedule.save!
      
      assert_equal 2, Log.count
      log = Log.last
      assert_equal :information, log.severity
      assert_equal "Schedule resumed", log.description
      assert_equal schedule, log.schedule
    end
    test "#{Schedule.opt_out_keyword} can't be used as a keyword in #{klass}" do
      assert_equal 'stop', Schedule.opt_out_keyword
      schedule = klass.new :keyword => Schedule.opt_out_keyword
      schedule.save

      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "The schedule keyword can't be the opt out keyword (#{Schedule.opt_out_keyword})"
      
      schedule = klass.new :keyword => 'STOP'
      schedule.save

      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "The schedule keyword can't be the opt out keyword, not even uppercase (#{Schedule.opt_out_keyword.upcase})"
      
      schedule = klass.new :keyword => 'stop'
      schedule.save

      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "The schedule keyword can't be the opt out keyword, not even lowercase (#{Schedule.opt_out_keyword.downcase})"
      
      schedule = klass.new :keyword => 'sTOp'
      schedule.save

      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?, "The schedule keyword can't be the opt out keyword, not even in random case (sTOp)"
    end
  end
end
