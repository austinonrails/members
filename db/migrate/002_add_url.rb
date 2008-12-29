class AddUrl < ActiveRecord::Migration
  def self.up
    add_column :members, :url, :string, :null => true
  end

  def self.down
  end
end
