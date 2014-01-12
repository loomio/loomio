class AddKeyToDiscussionsAndGroups < ActiveRecord::Migration
  def up
    add_column :discussions, :key, :string
    add_column :groups,      :key, :string

    add_index :discussions,  :key, unique: true
    add_index :groups,       :key, unique: true

    Discussion.reset_column_information
    Group.reset_column_information

    ActiveRecord::Base.record_timestamps = false

    begin
      puts "Creating keys for discussions (#{Discussion.all.count} records)"
      Discussion.find_each do |d|
        p d.id if d.id % 100 == 0
        if d.key.blank?
          d.update_attribute :key, d.send(:generate_unique_key)
        end
      end

      puts "Creating keys for groups (#{Group.all.count} records)"
      Group.find_each do |g|
        p g.id if g.id % 100 == 0
        if g.key.blank?
          g.update_attribute :key, g.send(:generate_unique_key)
        end
      end
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

  def down
    remove_index :groups, :column => :key
    remove_index :discussions, :column => :key

    remove_column :groups,      :key
    remove_column :discussions, :key
  end
end
