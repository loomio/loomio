class AddLogoToGroup < ActiveRecord::Migration
  def self.up
    add_attachment :groups, :logo
  end
  def self.down
    remove_attachment :groups, :logo
  end
end
