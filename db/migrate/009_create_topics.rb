class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name, :default => "", :null => false 
      t.integer :interest_count, :default => 0
      t.integer :expert_count, :default => 0
      t.integer :speaker_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
