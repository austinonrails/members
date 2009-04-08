class DropPasswordColumnFromMembers < ActiveRecord::Migration
  def self.up
    remove_column :members, :password
  end

  def self.down
    add_column :members, :password, :string
  end
end
