module NotificationDeliveryResolvers
  class ReactionCreated < NotificationDeliveryResolver
    def self.deduplication_key(reaction, occurrence_key: nil)
      "reaction_created:reaction_#{reaction.id}:#{reaction.updated_at.iso8601(6)}"
    end

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
      reaction = notification.subject
      unless reaction.is_a?(Reaction)
        raise ArgumentError, "reaction_created subject must be a Reaction"
      end

      reactable = reaction.reactable
      recipient = if reactable &&
                     reactable.author != reaction.user &&
                     reactable.group.memberships.exists?(user: reactable.author)
        User.active.where(id: reactable.author_id).to_a
      else
        []
      end

      { "in_app" => recipient }
    end
  end
end
