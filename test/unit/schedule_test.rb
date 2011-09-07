require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test "validate presence of required fields in schedule" do
    schedule = Schedule.new
    schedule.save
    
    assert schedule.invalid?
    assert !schedule.errors[:keyword].blank?
    assert !schedule.errors[:user_id].blank?
    assert !schedule.errors[:welcome_message].blank?
    assert !schedule.errors[:type].blank?    
  end
  
  [FixedSchedule, RandomSchedule].each do |klass|
    test "validate presence of required fields in #{klass}" do
      schedule = klass.new
      schedule.save
    
      assert schedule.invalid?
      assert !schedule.errors[:keyword].blank?
      assert !schedule.errors[:timescale].blank?
      assert !schedule.errors[:user_id].blank?
      assert !schedule.errors[:welcome_message].blank?
      assert !schedule.errors[:type].blank?    
    end
  end
  
  test "validate uniqueness of keyword" do
    schedule1 = RandomSchedule.create! :keyword => "schedule", :timescale => "weeks", :user_id => 1, :welcome_message => "foo"
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

  def send_ao (message)
    @messages_sent = @messages_sent << message
  end

  test "users are notified when schedule is destroyed" do

    Nuntium.expects(:new_from_config).returns(self).twice
    @messages_sent = []

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

    Nuntium.unstub(:find)

  end
  
  test "users are NOT notified when schedule is destroyed" do

    Nuntium.expects(:new_from_config).returns(self).twice
    @messages_sent = []

    pregnant = FixedSchedule.make :keyword => 'pregnant'
    first_subscriber = Subscriber.make :schedule => pregnant
    second_subscriber = Subscriber.make :schedule => pregnant

    #the following line simulates a UI-originated preference to NOT send messages to subscribers
    pregnant.notifySubscribers = false
    
    pregnant.destroy

    assert_equal 0, @messages_sent.size

    Nuntium.unstub(:find)

  end
end
