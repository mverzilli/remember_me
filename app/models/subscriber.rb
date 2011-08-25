class Subscriber < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :phone_number, :subscribed_at, :offset, :schedule_id
  validates_numericality_of :offset, :only_integer => true
    
  def self.subscribe params
    keyword, offset = params[:body].split
    user = User.find_by_email params[:'x-remindem-user']
    return reply(self.invalid_author(keyword), :to => params[:from]) unless user
    
    schedule = user.schedules.find_by_keyword keyword
    
    return reply(self.no_schedule_message(keyword), :to => params[:from]) unless schedule
    return reply(self.invalid_offset_message(params[:body], offset), :to => params[:from]) unless offset.nil? || offset.looks_as_an_int?
    
    new_subscriber = self.create! :phone_number => params[:from], 
                                        :offset => offset ? offset : 0, 
                                        :schedule => schedule,
                                        :subscribed_at => DateTime.current.utc
    
    schedule.generate_reminders :for => new_subscriber
    
    [schedule.build_message(params[:from], schedule.welcome_message)]
  end
  
  def reference_time
      self.subscribed_at - self.offset.send(self.schedule.timescale.to_sym)
  end
    
  def self.no_schedule_message keyword
    "Sorry, there's no reminder program named #{keyword} :(."
  end
  
  def self.invalid_offset_message body, offset
    "Sorry, we couldn't understand your message. You sent #{body}, but we expected #{offset} to be a number."
  end
  
  def self.invalid_author keyword
    "Sorry, there was a problem finding #{keyword} owner."
  end
    
  private 
  
  def self.reply msg, options
    [{:from => "remindem".with_protocol, :body => msg, :to => options[:to]}]
  end
end
