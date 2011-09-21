class Message < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :schedule
  validates_presence_of :offset,
    :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" },
    :message => "is required for schedules with a fixed timeline"
  validates_numericality_of :offset, :only_integer => true, :greater_than_or_equal_to => 0,
    :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" }
  
  before_destroy :alert_schedule_from_message_destroy
  after_update :alert_schedule_from_message_update
  after_create :alert_schedule_from_message_creation
  # serialize :occurrence_rule, IceCube::Rule

  #toDo: move this behavior to the schedule and remove the if's after merge
  
  def enqueue_dj_messages
    self.schedule.subscribers.each do |subscriber|
      if Time.now <  subscriber.reference_time + self.offset.send(self.schedule.timescale.to_sym) #if in the future
        schedule.schedule_message self, subscriber, subscriber.reference_time + self.offset.send(self.schedule.timescale.to_sym)
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
          updatedJob.save!
        else #if in the past
          updatedJob.destroy
        end
      end
    end
  end
  
  def next_occurrence_date_from date
    #Returns the new occurrence date, with the same time and localization than the given date
    rule.next_suggestion(date).to_time
  end
  
  def rule
    @rule ||= IceCube::Rule.from_yaml occurrence_rule
  rescue
    @rule ||= occurrence_rule
  end

  def alert_schedule_from_message_creation
    if schedule.class == CalendarBasedSchedule
      schedule.new_message_has_been_created self
    else
      enqueue_dj_messages
      schedule.log_message_created self
    end
  end

  def alert_schedule_from_message_destroy
    if schedule.class == CalendarBasedSchedule
      schedule.message_has_been_destroyed self
    else
      remove_dj_messages
      schedule.log_message_deleted self
    end
  end
  def alert_schedule_from_message_update
    if schedule.class == CalendarBasedSchedule
      schedule.message_has_been_updated self
    else
      update_dj_messages
      schedule.log_message_updated self
    end
  end
  
end
