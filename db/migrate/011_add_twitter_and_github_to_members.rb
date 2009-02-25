class AddTwitterAndGithubToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :twitter, :string, :default => ""
    add_column :members, :github, :string, :default => ""
  end

  def self.down
    remove_column :members, :twitter
    remove_column :members, :github
  end
end
