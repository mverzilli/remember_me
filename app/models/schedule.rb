class Schedule < ActiveRecord::Base
  validates_presence_of :keyword, :timescale, :user_id, :welcome_message, :type
  validates_uniqueness_of :keyword
  
  belongs_to :user
  
  has_many :messages
  has_many :subscribers
  
  def generate_reminders options
    recipient = options[:for]    
    messages = self.reminders
    
    messages.each_with_index do |message, index|
      self.enqueue_reminder message, index, recipient
    end
  end
end

class RandomSchedule < Schedule
  protected 
  
  def reminders
    res = self.messages.all
    res.shuffle!
  end
  
  def enqueue_reminder message, index, recipient
    Delayed::Job.enqueue ReminderJob.new(message.text, recipient.phone_number), :run_at => index.send(self.timescale.to_sym).from_now
  end
end

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