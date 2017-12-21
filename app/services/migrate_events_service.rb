module MigrateEventsService
  def self.migrate_edited_eventable
    Event.where(kind: ['poll_edited', 'discussion_edited'] ,
                eventable_type: "PaperTrail::Version").find_each do |event|
      version = event.eventable
      event.update_columns(eventable_type: version.item_type,
                             eventable_id: version.item_id,
                             custom_fields: {version_id: version.id,
                                             changed_keys: Hash(version.object_changes).keys})


    end
    Event.joins("LEFT OUTER JOIN polls on events.eventable_id = polls.id").where(eventable_type: "Poll").where("polls.id is null").destroy_all
  end
end
