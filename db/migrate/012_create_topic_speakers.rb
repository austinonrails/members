class CreateTopicSpeakers < ActiveRecord::Migration
  def self.up
    create_table :topic_speakers do |t|
      t.integer :member_id
      t.integer :topic_id
      t.timestamps
    end
    
    add_column :topics, :topic_speakers_count, :integer, :default => 0
  end

  def self.down
    drop_table :topic_speakers
    remove_column :topics, :topic_speakers_count
  end
end
