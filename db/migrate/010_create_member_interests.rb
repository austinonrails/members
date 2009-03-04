class CreateMemberInterests < ActiveRecord::Migration
  def self.up
    create_table :member_interests do |t|
      t.integer :member_id
      t.integer :topic_id
      t.boolean :is_interested, :default => false
      t.boolean :is_expert, :default => false
      t.boolean :will_speak, :default => false
      t.timestamps
    end
    
    add_column :topics, :interest_count, :integer, :default => 0
  end

  def self.down
    drop_table :member_interests
    remove_column :topics, :interest_count
  end
end
