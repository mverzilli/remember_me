class CalendarBasedSchedule < Schedule

  def sort_messages
    messages.sort_by!(&:next_ocurrence_date)
  end
  def generate_reminders_for subscriber
    next_message = next_message_from Time.now
    schedule_reminder_for subscriber, next_message.next_occurrence_date_from(Time.now)
  end
  
  def send_message_if_should_to subscriber, options = {}
    message_timestamp_cursor = options[:starting_at]
    if can_send_messages?
      p "cursor:"
      p message_timestamp_cursor
      p "messages to be sent"
      p messages_to_be_sent_on(message_timestamp_cursor)
      messages_to_be_sent_on(message_timestamp_cursor).each do |message_to_send|
        p "message to send:"
        p message_to_send
        send_message subscriber, message_to_send.text
      end
      next_message = next_message_from(message_timestamp_cursor)
      schedule_reminder_for subscriber, next_message.next_occurrence_date_from(message_timestamp_cursor)
    else
      schedule_reminder_for subscriber, message_timestamp_cursor, message_timestamp_cursor.next_day
    end
  end
  
  def schedule_reminder_for subscriber, message_timestamp_cursor, run_at=nil
    run_at ||= message_timestamp_cursor
    Delayed::Job.enqueue WakeUpEvent.new(subscriber.id, self.id, message_timestamp_cursor),
      :subscriber_id => subscriber.id,
      :run_at => run_at
  end
  
  def next_message_from timestamp #toDo Check this for the case of having 2 messages on the same day
    ice_cube_schedule = IceCube::Schedule.new(timestamp)
    messages.each do |message|
      ice_cube_schedule.add_recurrence_rule message.rule
    end
    occurrence = ice_cube_schedule.next_occurrence timestamp #Returns the next occurrence, with the same time and localization than the original date of the schedule
    messages_to_be_sent_on(occurrence.to_time).first
  end
  
  def messages_to_be_sent_on occurrence
    messages.select do |message|
      message.rule.validate_single_date occurrence
    end
  end
  
end