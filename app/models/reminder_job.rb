class ReminderJob < Struct.new(:text, :to, :schedule_id)
  def perform
      unless Schedule.find(self.schedule_id).paused? 
        nuntium = Nuntium.new_from_config()

        message = {
                    :from => "sms://remindem",
                    :subject => "",
                    :body => self.text,
                    :to => self.to
                  }
                
        nuntium.send_ao message
      end
  rescue ActiveRecord::RecordNotFound
    #If the record doesn't exist it's because the schedule was deleted, in which case the message mustn't be sent.
  end
end
