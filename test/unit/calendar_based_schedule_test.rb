require 'test_helper'

class CalendarBasedScheduleTest < ActiveSupport::TestCase
  
  def setup
    Time.expects(:now).returns(Time.utc(2011,"sep",6,20,15,1)).at_least_once()
    Nuntium.expects(:new_from_config).returns(self).at_least_once()
    @messages_sent = []
  end

  def send_ao (message)
    @messages_sent << message
  end
    
  test "new subscriber" do
    #   New Subscriber
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
    #   First message send
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
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    assert_equal 1, Delayed::Job.count
    Delayed::Job.first.delete
    assert_equal 0, Delayed::Job.count
  
    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
  
    Time.expects(:now).returns(Time.utc(2011,"sep",9,20,15,1)).at_least_once()
    
    wake_up_event.perform
  
    assert_equal 1, @messages_sent.size
    message_sent = @messages_sent[0]
    assert_equal message1.text, message_sent[:body]
      
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
  
    assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at
    
  end
  
  test "new message added" do
    #   New message added
    #     - check every subscribed user:
    #       - If the next occurrence (from today) happens after the next message timestamp cursor
    #           - do nothing
    #         else:
    #           - re-schedule the reminder job to send the new message, changing the cursor to the new message date, on the subscriber time.

    schedule = CalendarBasedSchedule.make
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
    subscriber = Subscriber.make :schedule => schedule
    schedule.generate_reminders_for subscriber
    
    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at
    
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)

    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at    

    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:saturday)

    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
    
  end
  
  test "reschedule send when scheduled message is deleted" do
    #   If the current scheduled event targets a message which has been deleted
    #     - Reschedule the wake up to the first event from today.
    #toDo
    
    schedule = CalendarBasedSchedule.make
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:monday)
    message3 = schedule.messages.create! :text => 'msg3' , :occurrence_rule => IceCube::Rule.weekly.day(:tuesday)
    subscriber = Subscriber.make :schedule => schedule
    schedule.generate_reminders_for subscriber
    
    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at

    Time.expects(:now).returns(Time.utc(2011,"sep",7,2,10,30)).at_least_once() #To force the right Delayed::Job lookup

    Message.destroy(message1.id)

    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at

    Message.destroy(message3.id)

    assert_equal 1, Delayed::Job.count
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",12,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",12,20,15,1), job.run_at
    
  end
  
  test "re-schedule message when it can't be sent" do
    #   Message can't be sent because of subscriber time zone
    #       (this happens when the server is offline during that time, and the message is sent when it gets back online)
    #     - Re-schedule the reminder job to send the message on the next day, on the subscriber time.
    #     - cursor remains.
 
    schedule = CalendarBasedSchedule.make
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    subscriber = Subscriber.make :schedule => schedule
    schedule.generate_reminders_for subscriber
    
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
  
    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
  
    Time.expects(:now).returns(Time.utc(2011,"sep",9,23,15,1)).at_least_once()
    Delayed::Job.first.delete    
    wake_up_event.perform
  
    assert_equal 0, @messages_sent.size
    
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",10,20,15,1), job.run_at

  end
  
  test "message sent after reschedule" do
    #   Message sent after reschedule.
    #     - Check new messages from the cursor date (In this case this means the last scheduled message date, yesterday maybe)
    #     - Schedule the next message (even if the schedule date is yesterday)
    #         This last two will do the trick of sending all the unsent messages from the last message to be sent.
    
    #Genero el schedule
    schedule = CalendarBasedSchedule.make
    message1 = schedule.messages.create! :text => 'msg1' , :occurrence_rule => IceCube::Rule.weekly.day(:friday)
    message2 = schedule.messages.create! :text => 'msg2' , :occurrence_rule => IceCube::Rule.weekly.day(:saturday)
    subscriber = Subscriber.make :schedule => schedule
    schedule.generate_reminders_for subscriber
    
    #Corre el primer día y rebota
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
  
    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",9,20,15,1), job.run_at
  
    Time.expects(:now).returns(Time.utc(2011,"sep",9,23,15,1)).at_least_once()
    Delayed::Job.first.delete    
    wake_up_event.perform
  
    assert_equal 0, @messages_sent.size
    
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",10,20,15,1), job.run_at

    #corre el segundo día y rebota
  
    Time.expects(:now).returns(Time.utc(2011,"sep",10,23,15,1)).at_least_once()
    Delayed::Job.first.delete    
    wake_up_event.perform
  
    assert_equal 0, @messages_sent.size
    
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    assert_equal Time.utc(2011,"sep",9,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",11,20,15,1), job.run_at
  
    #Corre el tercer día y manda los dos mensajes
    Time.expects(:now).returns(Time.utc(2011,"sep",11,20,15,1)).at_least_once()
    Delayed::Job.first.delete    
    wake_up_event.perform
  
    assert_equal 1, @messages_sent.size
    message_sent = @messages_sent[0]
    assert_equal message1.text, message_sent[:body]
    
    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    
    assert_equal Time.utc(2011,"sep",10,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",10,20,15,1), job.run_at

    Delayed::Job.first.delete    
    wake_up_event.perform
    
    assert_equal 2, @messages_sent.size
    message_sent = @messages_sent[1]
    assert_equal message2.text, message_sent[:body]

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    
    assert_equal Time.utc(2011,"sep",16,20,15,1), wake_up_event.message_timestamp_cursor
    assert_equal Time.utc(2011,"sep",16,20,15,1), job.run_at

  end
  
  test "new scheduled message when original sending has been delayed" do
    #   New scheduled message when original sending has been delayed
    #     - if it's after cursor, nothing. Even if it's before today, the new message must be sent, but not rescheduled.
    #     - if after today and before cursor, reschedule. In this case this won't happen.
    #toDo
  end
  
  test "two messages scheduled on the same date" do
    #   If I have 2 messages scheduled for the same day both must be sent
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
  
  test "message changes it's occurrence rule" do
    #   If the current scheduled event targets a message which occurrence rule is changed
    #     - If the new day falls between today and the cursor, the event must be rescheduled
    #     - If not, well, it's not necessary, but it's better if it's rescheduled to the first event from today...
    #       Even if the date stays the same
    #toDo
  end
  
end