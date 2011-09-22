require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup

    @create_channel_returns =  ActiveSupport::HashWithIndifferentAccess.new
    @create_channel_returns[:name]= 'the-channel-name'
    @create_channel_returns[:address]= 'sms://87425052'
    
    @user1 = users(:user1)
  end

  def create_channel(p1)
    @create_channel_p1 = p1
    return @create_channel_returns
  end
  
  def delete_channel(p1)
    @delete_channel_p1 = p1
  end
  
  test "Register channel with user as name" do
    @user1.register_channel '1245'

    assert_equal @user1.email.to_channel_name, @create_channel_p1[:name]
    assert_equal '1245', @create_channel_p1[:ticket_code]
    assert_not_nil @create_channel_p1[:configuration][:password]
    assert_equal "This phone will be used for reminders written by #{@user1.email}", @create_channel_p1[:ticket_message]
  end

  test "register stores name and address in user channel" do
    @user1.register_channel '1245'

    @user1.reload
    
    assert_not_nil @user1.channel
    assert_equal 'the-channel-name', @user1.channel.name
    assert_equal 'sms://87425052', @user1.channel.address
  end

  test "register first deletes current channel in nuntium" do
    @user1.create_channel :name => 'old-channel'
    assert_equal 1, Channel.all.count
    
    @user1.register_channel '1245'
    
    @user1.reload
    
    assert_not_nil @user1.channel
    assert_equal 'the-channel-name', @user1.channel.name
    assert_equal 1, Channel.all.count
    assert_equal @delete_channel_p1, 'old-channel'
  end
  
  test "register stores at_rules and restrictions of channel with user id" do
    @user1.register_channel '1245'

    assert_equal @user1.email.to_channel_name, @create_channel_p1[:name]
    assert_equal [{'matchings' => [], 'actions' => [{'property' => 'x-remindem-user', 'value' => @user1.email}], 'stop' => false}], @create_channel_p1[:at_rules]
    assert_equal [{'name' => 'x-remindem-user', 'value' => @user1.email}], @create_channel_p1[:restrictions]
  end
  
  test "channel registration with empty code is forbidden" do
    assert_raises Nuntium::Exception do
      @user1.register_channel ""
    end
  end
end
