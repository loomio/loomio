class AddKeyToMotionAndUser < ActiveRecord::Migration
    def up
      add_column :users,   :key, :string
      add_column :motions, :key, :string

      add_index :users,   :key, unique: true
      add_index :motions, :key, unique: true

      User.reset_column_information
      Motion.reset_column_information

      ActiveRecord::Base.record_timestamps = false
      begin
        puts "Creating keys for users (#{User.all.count} records)"
        User.find_each do |u|
          p u.id if u.id % 100 == 0
          if u.key.blank?
            u.update_attribute :key, u.send(:generate_unique_key)
          end
        end

        puts "Creating keys for motions (#{Motion.all.count} records)"
        Motion.find_each do |m|
          p m.id if m.id % 100 == 0
          if m.key.blank?
            m.update_attribute :key, m.send(:generate_unique_key)
          end
        end
      ensure
        ActiveRecord::Base.record_timestamps = true
      end
    end

    def down
      remove_index :motions, :column => :key
      remove_index :users, :column => :key

      remove_column :motions, :key
      remove_column :users,   :key
    end
end
