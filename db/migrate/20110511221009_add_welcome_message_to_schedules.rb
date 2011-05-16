class AddWelcomeMessageToSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :welcome_message, :string
  end

  def self.down
    remove_column :schedules, :welcome_message    
  end
end
