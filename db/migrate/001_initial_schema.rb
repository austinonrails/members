class InitialSchema < ActiveRecord::Migration
  def self.up
      create_table "members", :force => true do |t|
        t.column "first_name", :string, :limit => 50, :null => true
        t.column "last_name", :string, :limit => 50, :null => true 
        t.column "email", :string, :limit => 50,  :null => true 
        t.column "image_url", :string, :null => true 
        t.column "login", :string, :limit => 50, :default => "", :null => false 
        t.column "password", :string, :limit => 32, :default => "", :null => false 
        t.column "occupation_id", :integer, :null => true
      end

      create_table "occupations", :force => true do |t|
        t.column "name", :string, :null => false 
      end

  end

  def self.down
        drop_table :members
        drop_table :occupations
  end
end
