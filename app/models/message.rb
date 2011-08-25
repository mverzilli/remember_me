class Message < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :schedule
  validates_presence_of :offset, :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" }, :message => "is required for schedules with a fixed timeline"
  
  before_destroy :removeDJMessages
  after_update :updateDJMessages
  
  def removeDJMessages
    Delayed::Job.where("message_id = '#{self.id}'").map {|x| x.destroy}
  end
  
  def updateDJMessages
    if self.offset_changed?
      if Time.now > self.offset.send(Schedule.find(self.schedule_id).timescale.to_sym).from_now #if it's in the past
        Delayed::Job.where("message_id = '#{self.id}'").each do |x|
          x.destroy #delete all delayed jobs for given message
        end
      else #if we need to reschedule for the future
        Delayed::Job.where("message_id = '#{self.id}'").each do |x|
          updatedJob = x
          updatedJob.run_at = self.offset.send(Schedule.find(self.schedule_id).timescale.to_sym).from_now
          updatedJob.save! #update the times of all delayed jobs in the future
        end
      end
    end
  end
end
