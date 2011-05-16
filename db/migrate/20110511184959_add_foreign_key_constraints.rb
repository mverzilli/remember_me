class AddForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    change_table :messages do |t|
      t.references :schedule
    end
    
    execute <<-SQL
      ALTER TABLE messages
        ADD CONSTRAINT fk_messages_schedules
        FOREIGN KEY (schedule_id)
        REFERENCES schedules(id)
    SQL

    change_table :schedules do |t|
      t.references :user
    end
    
    execute <<-SQL
      ALTER TABLE schedules
        ADD CONSTRAINT fk_schedules_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL

    change_table :subscribers do |t|
      t.references :schedule
    end
    
    execute <<-SQL
      ALTER TABLE subscribers
        ADD CONSTRAINT fk_subscribers_schedules
        FOREIGN KEY (schedule_id)
        REFERENCES schedules(id)
    SQL
  end

  def self.down
    execute "ALTER TABLE subscribers DROP FOREIGN KEY fk_subscribers_schedules"
    remove_column :subscribers, :schedule_id
    
    execute "ALTER TABLE schedules DROP FOREIGN KEY fk_schedules_users"
    remove_column :schedules, :user_id
    
    execute "ALTER TABLE messages DROP FOREIGN KEY fk_messages_schedules"    
    remove_column :messages, :schedule_id
  end
end
