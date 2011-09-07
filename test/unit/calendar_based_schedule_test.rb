require 'test_helper'

class CalendarBasedScheduleTest < ActiveSupport::TestCase
  
  def setup
    Time.expects(:now).returns(Time.utc(2011,"sep",6,20,15,1)).at_least_once()
    Nuntium.expects(:new_from_config).returns(self).at_least_once()
    @messages_sent = []
  end

  def send_ao (message)
    p "message sent:"
    p message
    p "messages_sent before:"
    p @messages_sent
    @messages_sent << message
    p "messages_sent after:"
    p @messages_sent
  end
    
  test "new subscriber" do
    #   1: New Subscriber
    #     - Create Delayed Job with:
    #       - Next message time stamp cursor: First message time stamp
    #       - Message: First message text
    #       - When:
    #           Date: First message occurrence date
    #           Time: Subscriber time stamp time
    schedule = CalendarBasedSchedule.make
  
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
  
    subscriber = Subscriber.make :schedule => schedule
    
    schedule.generate_reminders_for subscriber
    
    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    
    wake_up_event = YAML.load(job.handler)
    
    #The first scheduled wake up is for Friday Septeber 9.
    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
    
  end
  
  test "new subscriber on different time than the schedule start" do
    schedule = CalendarBasedSchedule.make
  
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
  
    Time.expects(:now).returns(Time.local(2011,"sep",7,12,03,10)).at_least_once()
  
    subscriber = Subscriber.make :schedule => schedule
    
    schedule.generate_reminders_for subscriber
    
    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    
    Time.expects(:now).returns(Time.utc(2011,"sep",6,17,44,20)).at_least_once() #to force the right calculation of the hour
    
    #The first scheduled wake up is for Friday Septeber 9.
    assert_equal Time.local(2011,"sep",9,12,03,10), wake_up_event.message_timestamp_cursor
    assert_equal Time.local(2011,"sep",9,12,03,10), job.run_at
    
  end
  
  test "first message send" do
    #   2: First message send
    #     - Delayed Job executes and send the scheduled message.
    #       - Find next message to be sent starting from the cursor (In this case is the same than today).
    #       - Update Timestamp to next message date.
    #       - Schedule next message just like 1.
    #         - Create Delayed Job with:
    #           - Next message time stamp cursor: Next message time stamp
    #           - Message: Next message text
    #           - When:
    #               Date: Next message occurrence date
    #               Time: Subscriber time stamp time
    
    schedule = CalendarBasedSchedule.make
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
    subscriber = Subscriber.make :schedule => schedule
    schedule.generate_reminders_for subscriber
    
    assert_equal 1, Delayed::Job.count
    
    #Fake job execution on new date
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    assert_equal 1, Delayed::Job.count
    Delayed::Job.first.delete
    assert_equal 0, Delayed::Job.count
  
    #The first scheduled wake up is for Friday Septeber 9.
    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
  
    Time.expects(:now).returns(Time.utc(2011,"sep",9,20,15,1)).at_least_once()
    
    #The perform should schedule the next message and send the first one
    wake_up_event.perform
  
    assert_equal 1, @messages_sent.size
    message_sent = @messages_sent[0]
    assert_equal message1.text, message_sent[:body]
      
    #Find the new generated job
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
  
    #The second scheduled wake up is for Monday Septeber 12.
    assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at
    
  end
  
  test "new message added" do
    #   3: New message added
    #     -check every subscribed user:
    #       - If the next occurrence (from today) happens after the next message timestamp cursor
    #           - do nothing
    #         else:
    #           - re-schedule the reminder job to send the new message, changing the cursor to the new message date, on the subscriber time.
    #toDo
  end
  
  test "re-schedule message when it can't be sent" do
    #   4: Message can't be sent because of subscriber time zone
    #       (this happens when the server is offline during that time, and the message is sent when it gets back online)
    #     - Re-schedule the reminder job to send the message on the next day, on the subscriber time.
    #     - cursor remains.
    #toDo
  end
  
  test "message sent after reschedule" do
    #   5: Message sent after reschedule.
    #     - Just like 2.
    #     - Check new messages from the cursor date (In this case this means the last scheduled message date, yesterday maybe)
    #     - Schedule the next message (even if the schedule date is yesterday)
    #         This last two will do the trick of sending all the unsent messages from the last message to be sent.
    #toDo
  end
  
  test "new scheduled message when original sending has been delayed" do
    #   6: New scheduled message when original sending has been delayed
    #     - if it's after cursor, nothing. Even if it's before today, the new message must be sent, but not rescheduled.
    #     - if after today and before cursor, reschedule. In this case this won't happen.
    #toDo
  end
  
  test "two messages scheduled on the same date" do
    #   7: If I have 2 messages scheduled for the same day both must be sent
    #     - One for mondays and another for September 12, 2011.
    
     schedule = CalendarBasedSchedule.make
      message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
      message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
      message3 = schedule.messages.create! :text => 'msg3' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
      subscriber = Subscriber.make :schedule => schedule
      schedule.generate_reminders_for subscriber
  
      assert_equal 1, Delayed::Job.count
  
      #Fake job execution on new date
      job = Delayed::Job.first
      wake_up_event = YAML.load(job.handler)
      assert_equal 1, Delayed::Job.count
      Delayed::Job.first.delete
      assert_equal 0, Delayed::Job.count
  
      #The first scheduled wake up is for Friday Septeber 9.
      assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
      assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
  
      Time.expects(:now).returns(Time.utc(2011,"sep",9,20,15,1)).at_least_once()
  
      #The perform should schedule the next message and send the first one
      wake_up_event.perform
      p "messages sent"
      p @messages_sent
      assert_equal 2, @messages_sent.size
      message_sent = @messages_sent[0]
      assert_equal message1.text, message_sent[:body]
      message_sent = @messages_sent[1]
      assert_equal message2.text, message_sent[:body]
      
      #Find the new generated job
      assert_equal 1, Delayed::Job.count
      job = Delayed::Job.first
      wake_up_event = YAML.load(job.handler)
  
      #The second scheduled wake up is for Monday Septeber 12.
      assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
      assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at
      
  end

end