class ReminderJob < Struct.new(:to, :schedule_id, :message_id)
  def perform
    schedule = Schedule.find(self.schedule_id)
    message = schedule.messages.find(message_id)
    unless schedule.paused?
      schedule.send_message self.to, message.text
    end
  rescue ActiveRecord::RecordNotFound
    #If the record doesn't exist it's because the schedule was deleted, in which case the message mustn't be sent.
  end
end
