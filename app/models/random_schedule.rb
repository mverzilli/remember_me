class RandomSchedule < Schedule
  validates_presence_of :timescale
  
  def sort_messages
    messages.sort_by!( &:created_at)
  end

  protected
  
  def reminders
    self.messages.all.shuffle!
  end
  
  def enqueue_reminder message, index, recipient
    #this doesn't actually send once a day...
    Delayed::Job.enqueue ReminderJob.new(recipient.id, self.id, message.id),
      :message_id => message.id,
      :subscriber_id => recipient.id,
      :run_at => index.send(self.timescale.to_sym).from_now
  end
end