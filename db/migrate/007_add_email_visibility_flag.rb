class AddEmailVisibilityFlag < ActiveRecord::Migration
  def self.up
    add_column "members", "is_email_visible", :boolean, :default => true
  end

  def self.down
    remove_column "members", "is_email_visible"
  end
end
