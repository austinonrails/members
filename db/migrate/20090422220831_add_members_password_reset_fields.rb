class AddMembersPasswordResetFields < ActiveRecord::Migration
  def self.up  
    add_column :members, :perishable_token, :string, :default => "", :null => false  

    add_index :members, :perishable_token  
    add_index :members, :email  
  end  

  def self.down  
    remove_column :members, :perishable_token  
  end
end
