class Schedule < ActiveRecord::Base
  validates_presence_of :keyword, :timescale, :user_id, :welcome_message, :type
  validates_uniqueness_of :keyword
  
  belongs_to :user
  
  has_many :messages, :dependent => :destroy
  has_many :subscribers, :dependent => :destroy
  
  accepts_nested_attributes_for :messages, :allow_destroy => true
  validates_associated :messages
  before_validation :initialize_messages
  
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
end