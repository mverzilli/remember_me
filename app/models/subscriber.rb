class Subscriber < ActiveRecord::Base
  belongs_to :schedule
  
  validates_presence_of :phone_number, :subscribed_at, :offset, :schedule_id
  validates_numericality_of :offset, :only_integer => true

  def self.modify_subscription_according_to params
    keyword, offset = params[:body].split
    sender_phone_number = params[:from]
    
    user = User.find_by_email params[:'x-remindem-user']
    return reply(invalid_author(keyword), :to => sender_phone_number) unless user
    
    unless Schedule.is_opt_out_keyword? keyword
      schedule = user.schedules.find_by_keyword keyword
      return reply(no_schedule_message(keyword), :to => sender_phone_number) unless schedule
      
      return reply(already_registered_message(keyword), :to => sender_phone_number) if self.find_by_phone_number_and_schedule_id sender_phone_number, schedule.id
      
      return reply(invalid_offset_message(params[:body], offset), :to => sender_phone_number) unless offset.nil? || offset.looks_as_an_int?
      
      new_subscriber = create! :phone_number => sender_phone_number, 
                                          :offset => offset ? offset : 0, 
                                          :schedule => schedule,
                                          :subscribed_at => Time.now.utc
      schedule.subscribe new_subscriber
    else
      schedule = user.schedules.find_by_keyword offset
      if schedule
        subscriber = find_by_phone_number_and_schedule_id sender_phone_number, schedule
        if subscriber
          subscriber.destroy
          reply goodbye_message(schedule), :to => sender_phone_number
        else
          reply unkwnown_subscriber_message(offset), :to => sender_phone_number
        end
      else
        subscribers = find_all_by_phone_number sender_phone_number
        if subscribers.size == 1
          subscribers.first.destroy
          reply goodbye_message(subscribers.first.schedule), :to => sender_phone_number
        else
          reply please_specify_keyword_message(subscribers.collect {|a_subscriber| a_subscriber.schedule.keyword}), :to => sender_phone_number
        end
      end
    end
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
  
  def self.please_specify_keyword_message keywords
    "You are subscribed to: #{keywords}. Please specify the reminder you want to unsubscribe: 'off keyword'."
  end
  
  def self.unkwnown_subscriber_message keyword
    "Sorry, you are not subscribed to reminder program named #{keyword} :(."
  end
  
  def self.goodbye_message schedule
    "You have successfully unsubscribed from the \"#{schedule.title}\" Reminder. To subscribe again send \"#{schedule.keyword}\" to this number"
  end
  def self.already_registered_message keyword
    "Sorry, you are already subscribed to reminder program named #{keyword}. To unsubscribe please send 'stop #{keyword}'."
  end
  
  private 
  
  def self.reply msg, options
    [{:from => "remindem".with_protocol, :body => msg, :to => options[:to]}]
  end
end