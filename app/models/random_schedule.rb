class RandomSchedule < Schedule
  def sort_messages
    messages.sort_by!( &:created_at)
  end
  
  protected 
  
  def reminders
    res = self.messages.all
    res.shuffle!
  end
  
  def enqueue_reminder message, index, recipient
    Delayed::Job.enqueue ReminderJob.new(message.text , recipient.phone_number, self.id), :run_at => index.send(self.timescale.to_sym).from_now
  end
end