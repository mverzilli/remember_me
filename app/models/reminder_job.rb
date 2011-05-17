class ReminderJob < Struct.new(:text, :to)
  def perform
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