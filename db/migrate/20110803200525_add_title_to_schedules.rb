class AddTitleToSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :title, :string
  end

  def self.down
    remove_column :schedules, :title
  end
end
