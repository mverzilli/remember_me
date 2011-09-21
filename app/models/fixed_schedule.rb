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
    #TODO bugfix should use offset of recipient
    schedule_message message, recipient, message.offset.send(self.timescale.to_sym).from_now
  end
  
  def self.mode_in_words
    "Timeline"
  end
  
end