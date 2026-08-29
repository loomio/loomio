module NotificationDeliveryRouters
  class ReactionCreated < NotificationDeliveryRouter
    def translation_values
      {
        name: notification.actor.name,
        title: TranslationService.plain_text(subject_model.title_model, :title, notification.actor),
        reaction: subject_model.reaction.downcase,
        model: I18n.t("notification_models.#{subject_model.reactable.class.to_s.downcase}")
      }
    end

    def recipients_by_channel
      reaction = subject_model
      reactable = reaction.reactable
      users = if reactable &&
                 reactable.author != reaction.user &&
                 reactable.group.memberships.exists?(user: reactable.author)
        User.active.where(id: reactable.author_id)
      else
        User.none
      end
      recipients(users)
    end
  end
end
