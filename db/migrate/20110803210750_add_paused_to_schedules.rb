class AddPausedToSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :paused, :boolean
  end

  def self.down
    remove_column :schedules, :paused
  end
end
