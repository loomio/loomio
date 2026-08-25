class AddNotificationOccurrenceActorForeignKey < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :notification_occurrences,
                    :users,
                    column: :actor_id,
                    on_delete: :nullify
  end
end
