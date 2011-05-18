class FixedSchedule < Schedule
  protected
  
  def reminders
    res = self.messages.all
    res
  end
  
  def enqueue_reminder message, index, recipient
    Delayed::Job.enqueue ReminderJob.new(message.text, recipient.phone_number), :run_at => message.offset.send(self.timescale.to_sym).from_now
  end
end