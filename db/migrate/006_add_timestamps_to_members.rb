class AddTimestampsToMembers < ActiveRecord::Migration
  def self.up
    add_column "members", "created_at", :timestamp
    add_column "members", "updated_at", :timestamp
  end

  def self.down
    remove_column "members", "created_at"
    remove_column "members", "updated_at"
  end
end
