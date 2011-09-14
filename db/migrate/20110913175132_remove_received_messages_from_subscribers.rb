class RemoveReceivedMessagesFromSubscribers < ActiveRecord::Migration
  def self.up
    remove_column :subscribers, :received_messages
  end

  def self.down
    add_column :subscribers, :received_messages, :string
  end
end
