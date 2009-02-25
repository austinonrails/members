class CreateMemberInterests < ActiveRecord::Migration
  def self.up
    create_table :member_interests do |t|
      t.integer :member_id
      t.integer :topic_id
      t.timestamps
    end
    
    add_column :topics, :member_interests_count, :integer, :default => 0
  end

  def self.down
    drop_table :member_interests
    remove_column :topics, :member_interests_count
  end
end
