require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  
  def setup
    Nuntium.expects(:new_from_config).returns(self).at_most_once()
    @messages_sent = []
  end

  def teardown
    Nuntium.unstub(:find)
  end

  def send_ao (message)
    @messages_sent << message
  end
  
  test "updated message bodies are also updated in DJ queue" do
    #setup
    pregnant = pregnant_make
    
    
    #edit message text
    aSubscriber = pregnant.subscribers.find(:first)
    pregnant.generate_reminders :for => aSubscriber
    
    #grab the first message and edit it
    firstMessageID = pregnant.messages.find(:first).id
    message = pregnant.messages.find(firstMessageID)
    message.text = "Changed Message"
    message.save!
    
    Delayed::Job.where("message_id = '#{firstMessageID}'").each do |x|
      assert_equal "Changed Message", Message.find(x.message_id).text
    end
  end
  
  test "deleted messages are removed from DJ queue" do
    #setup
    pregnant = pregnant_make
    
    aSubscriber = pregnant.subscribers.find_by_offset(0)
    bSubscriber = pregnant.subscribers.find_by_offset(2)
    pregnant.generate_reminders :for => aSubscriber
    pregnant.generate_reminders :for => bSubscriber
    
    #delete message with given id
    firstMessageID = pregnant.messages.find(:first).id
    message = pregnant.messages.find(firstMessageID)
    
    assert_equal 2, Delayed::Job.where("message_id = '#{firstMessageID}'").size
    
    message.destroy
    
    assert_equal 0, Delayed::Job.where("message_id = '#{firstMessageID}'").size
  end
  
  test "messages updated to be sent in the past are deleted" do
    #setup
    pregnant = pregnant_make
    
    aSubscriber = pregnant.subscribers.find_by_offset(0)
    bSubscriber = pregnant.subscribers.find_by_offset(2)
    pregnant.generate_reminders :for => aSubscriber
    pregnant.generate_reminders :for => bSubscriber
    
    #grab a message
    message = pregnant.messages.first
    
    assert_equal 2, Delayed::Job.find_all_by_message_id(message.id).size
    
    #schedule it for the past
    message.offset = 1
    message.save!
    
    #verify that any messages are removed from the queue since they should no longer be sent
    assert_equal 1, Delayed::Job.find_all_by_message_id(message.id).size
  end
  
  test "messages updated to be sent in the future are rescheduled" do
    #setup
    pregnant = pregnant_make
    
    aSubscriber = pregnant.subscribers.find_by_offset(0)
    bSubscriber = pregnant.subscribers.find_by_offset(2)
    pregnant.generate_reminders :for => aSubscriber
    pregnant.generate_reminders :for => bSubscriber
    
    #grab a message
    message = pregnant.messages.first
    
    assert_equal 2, Delayed::Job.find_all_by_message_id(message.id).size
    
    #schedule it for the future
    message.offset = 28
    message.save!
    
    #verify that the messages remain in the queue
    assert_equal 2, Delayed::Job.find_all_by_message_id(message.id).size
    
    #verify that the run_at fields have been updated to reflect the new offset
    assert_in_delta aSubscriber.reference_time + 28.weeks, Delayed::Job.find_by_message_id_and_subscriber_id(message.id, aSubscriber.id).run_at, 5
    assert_in_delta bSubscriber.reference_time + 28.weeks, Delayed::Job.find_by_message_id_and_subscriber_id(message.id, bSubscriber.id).run_at, 5
  end
  
  test "add a message to a schedule adds delayed job" do
    #setup
    pregnant = pregnant_make
    aSubscriber = pregnant.subscribers.find_by_offset(0)
    bSubscriber = pregnant.subscribers.find_by_offset(2)
    
    #add a message
    message = pregnant.messages.create! :text => 'pregnant5', :offset => 1
    
    assert_equal 1, Delayed::Job.find_all_by_message_id(message.id).size #there should be two DJ for the two subscribers
    
    assert_in_delta aSubscriber.reference_time + 1.weeks, Delayed::Job.find_by_message_id_and_subscriber_id(message.id, aSubscriber.id).run_at, 5
  end
end
