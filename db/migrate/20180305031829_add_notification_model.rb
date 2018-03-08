class AddNotificationModel < ActiveRecord::Migration[5.1]
  def change
    Notification.joins(:event).where("events.kind": :reaction_created).each do |n|
      next unless n.eventable
      I18n.with_locale(n.locale) do
        e = Events::ReactionCreated.find(n.event_id)
        n.update(translation_values: e.send(:notification_translation_values))
      end
    end
  end
end
