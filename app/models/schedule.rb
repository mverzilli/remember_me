class Schedule < ActiveRecord::Base
  validates_presence_of :keyword, :user_id, :welcome_message, :type, :title
  validates_presence_of :timescale, :unless => Proc.new {|schedule| schedule.type == "CalendarBasedSchedule"}
  validates_uniqueness_of :keyword
  
  belongs_to :user
  
  has_many :messages, :dependent => :destroy
  has_many :subscribers, :dependent => :destroy
  has_many :logs, :dependent => :destroy
  
  accepts_nested_attributes_for :messages, :allow_destroy => true, :reject_if => lambda { |message| message[:text].blank?}
  validates_associated :messages
  before_validation :initialize_messages
  
  before_destroy :notify_deletion_to_subscribers
  before_update :log_if_paused_or_resumed
  
  attr_accessor_with_default :notifySubscribers, true

  def self.inherited(child)
    # force all subclass to have :schedule as model name
    child.instance_eval do
      def model_name
        Schedule.model_name
      end
    end
    super
  end
  
  def subscribe subscriber
    generate_reminders_for subscriber
    log_new_subscription_of subscriber.phone_number
    welcome_message_for subscriber.phone_number
  end
  
  def generate_reminders_for recipient
    messages = self.reminders
    
    messages.each_with_index do |message, index|
      self.enqueue_reminder message, index, recipient
    end
  end
  
  def welcome_message_for phone_number
    [build_message(phone_number, welcome_message)]
  end
  
  def self.time_scales
    ['hours', 'days', 'weeks', 'months', 'years']
  end
  
  def build_message to, body 
    self.user.build_message to, body 
  end

  def send_or_reschedule message, subscriber
    if !paused?
      if subscriber.can_receive_message
        send_message subscriber.phone_number, message.text
      else
        #TODO build a better estimate for when to reschedule
        try_to_send_it_at = Time.now.utc + 1.hour
        #TODO log warning, that it is reschedule due to invalid contact time
        schedule_message message, subscriber, try_to_send_it_at
      end
    else
      #TODO log that since it is paused, it is not sent
    end
  end
  
  # TODO remove all Delajed::Job.enqueue ReminderJob... for this method
  def schedule_message message, subscriber, send_at
    Delayed::Job.enqueue ReminderJob.new(subscriber.id, self.id, message.id), 
      :message_id => message.id, :subscriber_id => subscriber.id, :run_at => send_at
  end

  def send_message to, body 
    nuntium = Nuntium.new_from_config
    message = self.build_message to, body
    nuntium.send_ao message
    log_message_sent body, to
  end
  
  def log_message_sent body, recipient_number
    create_information_log_described_by "Message sent: " + body + " - recipient: " + recipient_number
  end
  
  def log_new_subscription_of recipient_number
    create_information_log_described_by "New subscriber: " + recipient_number + " - schedule: " + keyword
  end
  
  def create_information_log_described_by description
    Log.create! :schedule => self, :severity => :information, :description => description
  end
  
  def log_message_updated message
    create_information_log_described_by "Message updated: " + message.text
  end
  
  def log_message_deleted message
    create_information_log_described_by "Message deleted: " + message.text
  end
  
  def log_message_created message
    create_information_log_described_by "Message created: " + message.text
  end
  
  private
  
  def initialize_messages
    messages.each { |m| m.schedule = self }
  end 

  def notify_deletion_to_subscribers
    if notifySubscribers
      subscribers.each do |subscriber|
        self.send_message(subscriber.phone_number,
          "The schedule #{self.keyword} has been deleted. You will no longer receive messages from this schedule.")
      end
    end
  end
  
  def log_if_paused_or_resumed
    if paused_changed?
      if paused?
        log_schedule_paused
      else
        log_schedule_resumed
      end
    end
  end
  def log_schedule_paused
    create_information_log_described_by "Schedule paused"
  end
  def log_schedule_resumed
    create_information_log_described_by "Schedule resumed"
  end
  
  def mode_in_words
    raise NotImplementedError, 'Subclasses must redefine this message'
  end
  
end
