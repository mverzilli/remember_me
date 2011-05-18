module SchedulesHelper
  def setup_schedule(schedule)
    schedule.tap do |s|
      s.messages.build if s.messages.empty?
    end
  end
end
