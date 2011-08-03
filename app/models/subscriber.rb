class Subscriber < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :phone_number, :subscribed_at, :offset, :schedule_id
  validates_numericality_of :offset, :only_integer => true  
  
  def self.subscribe params
    keyword, offset = params[:body].split
    schedule = Schedule.find_by_keyword keyword
    
    return reply(no_schedule_message(keyword), :to => params[:from]) unless schedule
    return reply(invalid_offset_message(params[:body], offset), :to => params[:from]) unless offset.nil? || offset.looks_as_an_int?
    
    new_subscriber = create! :phone_number => params[:from], 
                                        :offset => offset ? offset : 0, 
                                        :schedule => schedule,
                                        :subscribed_at => DateTime.current.utc
    
    schedule.generate_reminders :for => new_subscriber
                                       
    [{:from => "rememberme".with_protocol, :to => params[:from], :body => schedule.welcome_message}]
  end
  
  def self.no_schedule_message keyword
    "Sorry, there's no reminder program named #{keyword} :(."
  end
  
  def self.invalid_offset_message body, offset
    "Sorry, we couldn't understand your message. You sent #{body}, but we expected #{offset} to be a number."
  end
    
  private 
  
  def self.reply msg, options
    [{:from => "rememberme".with_protocol, :body => msg, :to => options[:to]}]
  end
end
