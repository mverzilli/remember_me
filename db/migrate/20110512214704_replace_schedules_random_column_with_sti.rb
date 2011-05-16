class ReplaceSchedulesRandomColumnWithSti < ActiveRecord::Migration
  def self.up
    remove_column :schedules, :random
    add_column :schedules, :type, :string
  end

  def self.down
    remove_column :schedules, :type
    add_column :schedules, :random, :boolean
  end
end
