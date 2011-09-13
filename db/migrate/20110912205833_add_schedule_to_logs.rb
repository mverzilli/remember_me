class AddScheduleToLogs < ActiveRecord::Migration
  def self.up
     add_column :logs, :schedule_id, :integer, :default => 0
  end

  def self.down
    remove_column :logs, :schedule_id
  end
end
