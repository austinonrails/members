class KillUsers < ActiveRecord::Migration
  def self.up
    Member.destroy_all
  end

  def self.down
  end
end
