class CalendarBasedSchedule < Schedule

  def sort_messages
    messages.sort_by! do |message|
      message.next_occurrence_date_from Time.now
    end
  end
  
  def generate_reminders_for subscriber
    schedule_reminder_for subscriber, next_message_occurrence_from(Time.now)
  end
  
  def send_message_if_should_to subscriber, options = {}
    message_timestamp_cursor = options[:starting_at]
    if !paused? && between_two_hours_of(message_timestamp_cursor)
      messages_to_be_sent_on(message_timestamp_cursor).each do |message_to_send|
        send_message subscriber.phone_number, message_to_send.text
      end
      schedule_reminder_for subscriber, next_message_occurrence_from(message_timestamp_cursor)
    else
      schedule_reminder_for subscriber,
        message_timestamp_cursor,
        message_timestamp_cursor + ((Time.now.getutc.yday - message_timestamp_cursor.getutc.yday + 1) * one_day)
    end
  end
  
  def schedule_reminder_for subscriber, message_timestamp_cursor, run_at=nil
    run_at ||= message_timestamp_cursor
    Delayed::Job.enqueue WakeUpEvent.new(subscriber.id, self.id, message_timestamp_cursor),
      :subscriber_id => subscriber.id,
      :run_at => run_at
  end
  
  def next_message_occurrence_from timestamp
    ice_cube_schedule = IceCube::Schedule.new(timestamp)
    messages.each do |message|
      ice_cube_schedule.add_recurrence_rule message.rule
    end
    #Returns the next event occurrence, with the same time and localization than the original date of the schedule
    ice_cube_schedule.next_occurrence timestamp
  end
  
  def messages_to_be_sent_on occurrence
    messages.select do |message|
      message.rule.validate_single_date occurrence
    end
  end
  
  def message_has_been_updated message
    # I don't search only for the scheduled jobs of that message
    # because of the new rule the message could now stand before any other message scheduled for any subscriber
    self.subscribers.each do |subscriber|
      delayed_job = Delayed::Job.where(:subscriber_id => subscriber.id).first
      wake_up_event = YAML.load(delayed_job.handler)
      schedule_reminder_for subscriber, next_message_occurrence_from(today_at_the_same_time_than wake_up_event.message_timestamp_cursor)
      Delayed::Job.destroy(delayed_job.id)
    end
  end
  
  def message_has_been_destroyed message
    deleted_message_next_occurrence_date = message.next_occurrence_date_from(Time.now)
    self.subscribers.each do |subscriber|
      delayed_job = Delayed::Job.where(:subscriber_id => subscriber.id).first
      #I make the comparisson for yday because the occurrences are saved on the subscriber's time
      if delayed_job.run_at.getutc.yday == deleted_message_next_occurrence_date.getutc.yday
        wake_up_event = YAML.load(delayed_job.handler)
        schedule_reminder_for subscriber, next_message_occurrence_from(wake_up_event.message_timestamp_cursor)
        Delayed::Job.destroy(delayed_job.id)
      end
    end
  end
  
  def new_message_has_been_created message
    new_message_next_occurrence_date = message.next_occurrence_date_from(Time.now)
    
    self.subscribers.each do |subscriber|
      delayed_job = Delayed::Job.where(:subscriber_id => subscriber.id).first
      if delayed_job.run_at > new_message_next_occurrence_date
        schedule_reminder_for subscriber, new_message_next_occurrence_date
        Delayed::Job.destroy(delayed_job.id)
      end
    end
  end
  
  def between_two_hours_of timestamp
    timestamp_at_today = today_at_the_same_time_than timestamp
    
    Time.now.between?(timestamp_at_today - two_hours, timestamp_at_today + two_hours)
  end
  
  def two_hours
    #messages + and - from Time adds and subtracts a measure in seconds 
    60 * 60 * 2
  end
  
  def one_day
    60 * 60 * 24
  end
  
  def today_at_the_same_time_than timestamp
    timestamp + (Time.now.getutc.yday - timestamp.getutc.yday) * one_day
  end
  
end