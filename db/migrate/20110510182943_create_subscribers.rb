class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.string :phone_number
      t.datetime :subscribed_at
      t.integer :offset
      t.string :received_messages

      t.timestamps
    end
  end

  def self.down
    drop_table :subscribers
  end
end
