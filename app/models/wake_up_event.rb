class WakeUpEvent < Struct.new(:subscriber_id, :schedule_id, :message_timestamp_cursor)
    def perform
      schedule = Schedule.find(self.schedule_id)
      subscriber = Subscriber.find(self.subscriber_id)
      schedule.send_message_if_should_to subscriber, starting_at: message_timestamp_cursor
    rescue ActiveRecord::RecordNotFound
      #If the record doesn't exist it's because the schedule was deleted, in which case no further messages must be sent.
    end
  end
  