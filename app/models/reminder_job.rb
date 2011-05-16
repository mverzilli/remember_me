class ReminderJob < Struct.new(:text, :to)
  def perform
  end
end