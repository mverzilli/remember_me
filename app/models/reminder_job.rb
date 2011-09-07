class ReminderJob < Struct.new(:subscriber_id, :schedule_id, :message_id)
  def perform
    schedule = Schedule.find(self.schedule_id)
    message = schedule.messages.find(message_id)
    subscriber = Subscriber.find(self.subscriber_id)
    schedule.send_if_should message, to: subscriber
  rescue ActiveRecord::RecordNotFound
    #If the record doesn't exist it's because the schedule was deleted, in which case the message mustn't be sent.
  end
end
