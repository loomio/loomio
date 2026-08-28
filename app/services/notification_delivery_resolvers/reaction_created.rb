module NotificationDeliveryResolvers
  class ReactionCreated < NotificationDeliveryResolver
    def self.translation_values(reaction, actor, locale: actor.locale)
      I18n.with_locale(locale) do
        {
          name: actor.name,
          title: TranslationService.plain_text(reaction.title_model, :title, actor),
          reaction: reaction.reaction.downcase,
          model: I18n.t("notification_models.#{reaction.reactable.class.to_s.downcase}")
        }
      end
    end

    private

    def recipients_by_channel
      reaction = notification.subject_model
      unless reaction.is_a?(Reaction)
        raise ArgumentError, "reaction_created subject must be a Reaction"
      end

      reactable = reaction.reactable
      recipient_scope = if reactable &&
                           reactable.author != reaction.user &&
                           reactable.group.memberships.exists?(user: reactable.author)
        User.active.where(id: reactable.author_id)
      else
        User.none
      end
      push_scope = if recipient_scope.none?
        User.none
      elsif (topic = notification_topic)
        topic.push_enabled_members
      elsif (group = notification_group)
        group.push_enabled_members
      else
        User.where(volume_push_default: User.volume_push_defaults.values_at("normal", "loud"))
      end

      user_recipients_by_channel(recipient_scope, email: User.none, push: push_scope)
    end
  end
end
