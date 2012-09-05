class AddUserToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    belongs_to :eventable, :polymorphic => true
  end

  def up
    add_column :events, :user_id, :integer
    add_index :events, :user_id

    Event.reset_column_information
    Event.where(:kind => "close_motion").each do |event|
      event.user_id = event.eventable.author_id
      event.save(:validate => false)
    end
  end

  def down
    remove_index :events, :user_id
    remove_column :events, :user_id
  end
end
