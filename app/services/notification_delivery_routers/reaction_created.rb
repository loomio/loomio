module NotificationDeliveryRouters
  class ReactionCreated < NotificationDeliveryRouter
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

    subject_model_class Reaction

    def recipients_by_channel
      reaction = subject_model
      reactable = reaction.reactable
      in_app_recipients = if reactable &&
                           reactable.author != reaction.user &&
                           reactable.group.memberships.exists?(user: reactable.author)
        User.active.where(id: reactable.author_id)
      else
        User.none
      end
      recipients(in_app_recipients)
    end
  end
end
