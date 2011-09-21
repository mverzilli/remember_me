class Subscriber < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :phone_number, :subscribed_at, :offset, :schedule_id
  validates_numericality_of :offset, :only_integer => true
    
  def self.subscribe params
    keyword, offset = params[:body].split
    user = User.find_by_email params[:'x-remindem-user']
    sender_phone_number = params[:from]
    return reply(self.invalid_author(keyword), :to => sender_phone_number) unless user
    
    schedule = user.schedules.find_by_keyword keyword
    
    return reply(self.no_schedule_message(keyword), :to => sender_phone_number) unless schedule
    return reply(self.invalid_offset_message(params[:body], offset), :to => sender_phone_number) unless offset.nil? || offset.looks_as_an_int?
    
    new_subscriber = self.create! :phone_number => sender_phone_number, 
                                        :offset => offset ? offset : 0, 
                                        :schedule => schedule,
                                        :subscribed_at => Time.now.utc
    
    schedule.subscribe new_subscriber
  end
  
  def reference_time
      self.subscribed_at - self.offset.send(self.schedule.timescale.to_sym)
  end
  
  def can_receive_message
    # iif we are +/-2 hours from subscription time
    (Time.now.utc.seconds_since_midnight - self.subscribed_at.seconds_since_midnight).abs.seconds < 2.hours
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
