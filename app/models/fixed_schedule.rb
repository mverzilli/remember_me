class FixedSchedule < Schedule
  validates_presence_of :timescale
  
  def sort_messages
    messages.sort_by!(&:offset)
  end
  
  def expected_delivery_time message, subscriber
    subscriber.reference_time + message.offset.send(self.timescale.to_sym)
  end
  
  def reminders
    self.messages.all
  end
  
  def enqueue_reminder message, index, recipient
    schedule_message message, recipient, expected_delivery_time(message, recipient)
  end
  
  def self.mode_in_words
    "Timeline"
  end
  
  def duration
    sort_messages.last.offset
  end
  
end