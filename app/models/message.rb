class Message < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :schedule
  validates_presence_of :offset, :if => lambda { !marked_for_destruction? && schedule.type == "FixedSchedule" }, :message => "is required for schedules with a fixed timeline"
end
