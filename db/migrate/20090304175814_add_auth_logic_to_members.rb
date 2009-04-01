class AddAuthLogicToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :crypted_password, :string
    add_column :members, :password_salt, :string
    add_column :members, :persistence_token, :string
    add_column :members, :login_count, :integer
    add_column :members, :last_request_at, :datetime
    add_column :members, :last_login_at, :datetime
    add_column :members, :current_login_at, :datetime
    add_column :members, :last_login_ip, :string
    add_column :members, :current_login_ip, :string
  end

  def self.down
    remove_column :members, :current_login_ip
    remove_column :members, :last_login_ip
    remove_column :members, :current_login_at
    remove_column :members, :last_login_at
    remove_column :members, :last_request_at
    remove_column :members, :login_count
    remove_column :members, :persistence_token
    remove_column :members, :password_salt
    remove_column :members, :crypted_password
  end
end
