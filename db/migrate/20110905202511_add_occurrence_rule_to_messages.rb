class AddOccurrenceRuleToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :occurrence_rule, :text
  end

  def self.down
    remove_column :messages, :occurrence_rule
  end
end