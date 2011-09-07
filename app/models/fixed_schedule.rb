class FixedSchedule < Schedule
  validates_presence_of :timescale
  
  def sort_messages
    messages.sort_by!(&:offset)
  end
  
  protected
  
  def reminders
    self.messages.all
  end
  
  def enqueue_reminder message, index, recipient
    Delayed::Job.enqueue ReminderJob.new(recipient.id, self.id, message.id), :message_id => message.id, :subscriber_id => recipient.id, :run_at => message.offset.send(self.timescale.to_sym).from_now
  end
end