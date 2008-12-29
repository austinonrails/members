class AddBioToMembers < ActiveRecord::Migration
  def self.up
    add_column "members", "bio", :string, :limit => 320
  end

  def self.down
    remove_column "members", "bio"
  end
end
