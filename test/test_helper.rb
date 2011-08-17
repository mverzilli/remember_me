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
    pregnant = FixedSchedule.make :keyword => 'pregnant', :timescale => 'weeks'
    pregnant.messages.create! :text => 'pregnant1', :offset => 3
    pregnant.messages.create! :text => 'pregnant2', :offset => 11
    pregnant.messages.create! :text => 'pregnant3', :offset => 17
    pregnant.messages.create! :text => 'pregnant4', :offset => 23
    pregnant.messages.create! :text => 'pregnant5', :offset => 36
    
    #Subscriber.make :schedule => pregnant, :phone_number => 'sms://4000', :offset => 0
    #Subscriber.make :schedule => pregnant, :phone_number => 'sms://4001', :offset => 1
    
    return pregnant
  end
  
  def randweeks_make
    randweeks = RandomSchedule.make :keyword => 'randweeks', :timescale => 'weeks', :welcome_message => 'welcome', :paused => true
    randweeks.messages.create! :text => 'msg1'
    randweeks.messages.create! :text => 'msg2'
    randweeks.messages.create! :text => 'msg3'
    randweeks.messages.create! :text => 'msg4'
    randweeks.messages.create! :text => 'msg5'

    # Subscriber.make :schedule => pregnant, :phone_number => 'sms://5000', :offset => 0
    
    return randweeks
  end
  
  def one_make
    one = RandomSchedule.make :keyword => 'one', :timescale => 'weeks', :welcome_message => 'foo'
    one.messages.create! :text => 'MyString'
    one.messages.create! :text => 'MyString'
    one.messages.create! :text => 'MyString'
    
    return one
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
  include Mocha::API
end