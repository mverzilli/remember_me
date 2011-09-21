ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require File.expand_path('../blueprints', __FILE__)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  include Mocha::API
  
  def pregnant_make
    schedule = FixedSchedule.make :keyword => 'pregnant', :timescale => 'weeks'
    schedule.messages.create! :text => 'pregnant1', :offset => 3
    schedule.messages.create! :text => 'pregnant2', :offset => 11
    schedule.messages.create! :text => 'pregnant3', :offset => 17
    schedule.messages.create! :text => 'pregnant4', :offset => 23
    schedule.messages.create! :text => 'pregnant5', :offset => 36
    
    Subscriber.make :schedule => schedule, :phone_number => 'sms://4000', :offset => 0
    Subscriber.make :schedule => schedule, :phone_number => 'sms://4001', :offset => 2
    
    return schedule
  end
  
  def randweeks_make
    schedule = RandomSchedule.make :keyword => 'randweeks', :timescale => 'weeks', :welcome_message => 'welcome', :paused => true
    schedule.messages.create! :text => 'msg1'
    schedule.messages.create! :text => 'msg2'
    schedule.messages.create! :text => 'msg3'
    schedule.messages.create! :text => 'msg4'
    schedule.messages.create! :text => 'msg5'

    Subscriber.make :schedule => schedule, :phone_number => 'sms://5000', :offset => 0
    
    return schedule
  end
  
  def one_make
    schedule = RandomSchedule.make :keyword => 'one', :timescale => 'weeks', :welcome_message => 'foo'
    schedule.messages.create! :text => 'MyString'
    schedule.messages.create! :text => 'MyString'
    schedule.messages.create! :text => 'MyString'
    
    return schedule
  end
    
  # Sets current time as a stub on Time.now
  def set_current_time(time=Time.at(946702800).utc)
    Time.stubs(:now).returns(time)
  end

  # Returns base time to be used for tests in utc
  def base_time
    return Time.at(946702800).utc
  end
  
  def time_advance(span)
    set_current_time(Time.now + span)
    Delayed::Worker.new.work_off
  end 
  
  # begin mock and Assert Nuntium
  setup do 
    Nuntium.stubs(:new_from_config).returns(self)
    clear_messages
  end
  
  def send_ao(message)
    @messages_sent = @messages_sent << message
  end
  
  def messages_to(phone)
    @messages_sent.find_all { |m| m[:to] == phone }
  end

  def assert_no_message_sent(phone)
    assert messages_to(phone).empty?, "The following messages were not expected to be sent #{messages_to(phone)}"
  end
  
  def assert_message_sent(phone, text)
    assert messages_to(phone).any? { |m| m[:body].match(text) }, "#{phone} did not receive expected message: #{text}"
  end
  
  def clear_messages
    @messages_sent = []
  end
  # end
end

class ActionController::TestCase
  include Devise::TestHelpers
  include Mocha::API
end