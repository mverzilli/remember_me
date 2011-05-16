require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  
  test "validate presence of required fields" do
    schedule = Schedule.new
    schedule.save
    
    assert schedule.invalid?
    assert !schedule.errors[:keyword].blank?
    assert !schedule.errors[:timescale].blank?
    assert !schedule.errors[:user_id].blank?
    assert !schedule.errors[:welcome_message].blank?
    assert !schedule.errors[:type].blank?    
  end
  
  test "validate uniqueness of keyword" do
    schedule1 = RandomSchedule.create! :keyword => "schedule", :timescale => "weeks", :user_id => 1, :welcome_message => "foo"
    schedule2 = Schedule.new :keyword => "schedule"    
    schedule2.save
    
    assert schedule2.invalid?
    assert !schedule2.errors[:keyword].blank?
  end
  
  test "generate random reminders" do    
    subscriber = subscribers(:one)
    randweeks = schedules(:randweeks)
    randweeks.generate_reminders :for => subscriber

    messages = (1..5).map { |i| messages("msg#{i}") }
    sent_at = (1..5).map { |i| subscriber.subscribed_at + i.send(randweeks.timescale.to_sym) }
    
    assert_equal 5, Delayed::Job.count
    
    Delayed::Job.all.each do |job|
      reminder_job = YAML.load(job.handler)
      
      assert_equal 1, messages.select {|msg| msg.text == reminder_job.text}.length
      assert_equal 1, (0..4).select {|i| (job.run_at.to_f - (subscriber.subscribed_at + i.weeks).to_f).abs <= 1.minute.to_f }.length
    end
  end

  test "generate fixed reminders" do
    subscriber = subscribers(:two)
    pregnant = schedules(:pregnant)
    pregnant.generate_reminders :for => subscriber

    messages = (1..5).map { |i| messages("pregnant#{i}") }

    assert_equal 5, Delayed::Job.count
    
    Delayed::Job.order(:run_at).each_with_index do |job, index|
      reminder_job = YAML.load(job.handler)
      
      assert_equal messages[index].text, reminder_job.text
      assert job.run_at.to_f - (subscriber.subscribed_at + messages[index].offset.weeks).to_f.abs <= 1.minute.to_f
    end
  end
end
