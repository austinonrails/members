class KillUsers < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM `members`;"
  end

  def self.down
  end
end
