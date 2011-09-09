class Schedule < ActiveRecord::Base
  validates_presence_of :keyword, :user_id, :welcome_message, :type
  # validates_presence_of :timescale, :unless => Proc.new {|schedule| schedule.type == "CalendarBasedSchedule"}
  validates_uniqueness_of :keyword
  
  belongs_to :user
  
  has_many :messages, :dependent => :destroy
  has_many :subscribers, :dependent => :destroy
  
  accepts_nested_attributes_for :messages, :allow_destroy => true, :reject_if => lambda { |message| message[:text].blank?}
  validates_associated :messages
  before_validation :initialize_messages
  
  before_destroy :notify_deletion_to_subscribers
  
  attr_accessor_with_default :notifySubscribers, true
  
  def generate_reminders_for recipient
    messages = self.reminders
    
    messages.each_with_index do |message, index|
      self.enqueue_reminder message, index, recipient
    end
  end
  
  def self.time_scales
    ['hours', 'days', 'weeks', 'months', 'years']
  end
  
  def build_message to, body 
    self.user.build_message to, body 
  end

  #toDo: remove default behavior
  def send_if_should message, options = {}
    if can_send_messages?
      send_message options[:to].phone_number, message.text
    end
  end

  def can_send_messages?
    !paused? #and it's not 3am?
  end

  def send_message to, body 
    nuntium = Nuntium.new_from_config
    message = self.build_message to, body
    nuntium.send_ao message
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
end
