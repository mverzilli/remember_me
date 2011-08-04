class ReminderJob < Struct.new(:text, :to, :shcedule_id)
  def perform
    unless (Schedule.find schedule_id).paused? do
      nuntium = Nuntium.new_from_config()
    
      message = {
                  :from => "sms://rememberme",
                  :subject => "",
                  :body => self.text,
                  :to => self.to
                }
              
      nuntium.send_ao message
    end
  end
end