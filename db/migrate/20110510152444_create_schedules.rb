class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :keyword
      t.string :timescale
      t.boolean :random

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
