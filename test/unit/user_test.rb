require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    Nuntium.expects(:new_from_config).returns(self).at_most_once
  end
  
  def create_channel(p1)
    @create_channel_p1 = p1
    return @create_channel_returns
  end
  
  def delete_channel(p1)
    @delete_channel_p1 = p1
  end
  
  test "Register channel with user as name" do
    @user1 = users(:user1)

    @create_channel_returns = { :name => 'the-channel-name', :address => 'sms://87425052'  }    
    @user1.register_channel '1245'

    assert_equal @user1.email.to_channel_name, @create_channel_p1[:name]
    assert_equal '1245', @create_channel_p1[:ticket_code]
    assert_equal "This phone will be used for reminders written by #{@user1.email}", @create_channel_p1[:ticket_message]
  end

  test "register stores name and address in user channel" do
    @user1 = users(:user1)
    
    @create_channel_returns = { :name => 'the-channel-name', :address => 'sms://87425052'  }
    @user1.register_channel '1245'

    @user1.reload
    
    assert_not_nil @user1.channel
    assert_equal 'the-channel-name', @user1.channel.name
    assert_equal 'sms://87425052', @user1.channel.address
  end

  test "register first deletes current channel in nuntium" do
    @user1 = users(:user1)
    @user1.build_channel :name => 'old-channel'
    
    @create_channel_returns = { :name => 'the-channel-name', :address => 'sms://87425052'  }
    @user1.register_channel '1245'
    
    @user1.reload
    
    assert_not_nil @user1.channel
    assert_equal 'the-channel-name', @user1.channel.name
    assert_equal 1, Channel.all.count
    assert_equal @delete_channel_p1, 'old-channel'
  end
  
  # "register stores at_rules and restrictions of channel with user id"
end
