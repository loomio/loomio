module NotificationDeliveryRouters
  class ReactionCreated < NotificationDeliveryRouter
    handles :reaction_created

    def translation_values
      {
        name: actor_name,
        title: TranslationService.plain_text(subject_model.title_model, :title, notification.actor),
        reaction: subject_model.reaction.downcase,
        model: model_noun
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

    private

    def model_noun
      reactable = subject_model.reactable
      return I18n.t("poll_types.#{reactable.poll_type}") if reactable.is_a?(Poll)

      I18n.t("notification_nouns.#{reactable.class.to_s.downcase}")
    end
  end
end
