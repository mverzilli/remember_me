class Message < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :schedule
  validates_presence_of :offset, :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" }, :message => "is required for schedules with a fixed timeline"
  
  before_destroy :remove_dj_messages
  after_update :update_dj_messages
  
  after_create :enqueue_dj_messages
  
  def enqueue_dj_messages
    self.schedule.subscribers.each do |subscriber|
      if Time.now <  subscriber.reference_time + self.offset.send(self.schedule.timescale.to_sym) #if not in the past...
        Delayed::Job.enqueue ReminderJob.new(subscriber.phone_number, self.schedule.id, self.id), :message_id => self.id, :subscriber_id => subscriber.id, :run_at => subscriber.reference_time + self.offset.send(self.schedule.timescale.to_sym)
      end
    end
  end
  
  def remove_dj_messages
    Delayed::Job.where("message_id = '#{self.id}'").map {|x| x.destroy}
  end
  
  def update_dj_messages
    if self.offset_changed?
      Delayed::Job.where("message_id = '#{self.id}'").each do |updatedJob|
        updatedJob.run_at = Subscriber.find(updatedJob.subscriber_id).reference_time + self.offset.send(self.schedule.timescale.to_sym)
        if Time.now < updatedJob.run_at #if in future
          updatedJob.save! #update the times of all delayed jobs in the future
        else
          updatedJob.destroy
        end
      end
    end
  end
end
