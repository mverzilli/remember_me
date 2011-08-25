class AddMessageSubscriberId < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :message_id, :integer, :default => 0
    add_column :delayed_jobs, :subscriber_id, :integer, :default => 0
  end

  def self.down
    remove_column :delayed_jobs, :message_id
    remove_column :delayed_jobs, :subscriber_id
  end
end
