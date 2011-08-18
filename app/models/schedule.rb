class Schedule < ActiveRecord::Base
  validates_presence_of :keyword, :timescale, :user_id, :welcome_message, :type
  validates_uniqueness_of :keyword
  
  belongs_to :user
  
  has_many :messages, :dependent => :destroy
  has_many :subscribers, :dependent => :destroy
  
  accepts_nested_attributes_for :messages, :allow_destroy => true
  validates_associated :messages
  before_validation :initialize_messages
  
  before_destroy :notify_deletion_to_subscribers
  
  attr_accessor_with_default :notifySubscribers, false
  
  def generate_reminders options
    recipient = options[:for]    
    messages = self.reminders
    
    messages.each_with_index do |message, index|
      self.enqueue_reminder message, index, recipient
    end
  end
  
  def self.time_scales
    ['hours', 'days', 'weeks', 'months', 'years']
  end
  
  private
  
  def initialize_messages
    messages.each { |m| m.schedule = self }
  end  

  def notify_deletion_to_subscribers
    if notifySubscribers
      subscribers.each do |subscriber|
        #ask the user if he or she wants to notify subscribers of deletion
        ReminderJob.new(
          "The schedule #{self.keyword} has been deleted, you will no longer receive messages from this schedule.",
          subscriber.phone_number,
          self.id).perform
        end
    end
  end
end
