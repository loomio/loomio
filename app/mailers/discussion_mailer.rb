class DiscussionMailer < BaseMailer


  def new_discussion_created(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'
    token = EmailIntegration.create(user: user, email_integrable: discussion).token
    reply_email = ENV['GMAIL_REPLY_USERNAME'] || discussion.author.email
    locale = best_locale(user.language_preference, discussion.author.language_preference)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: "#{discussion.author.name} <noreply@loomio.org>",
            reply_to: inject_reply_token(token, "#{discussion.author.name} <#{reply_email}>"),
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_discussion.subject", which: @discussion.title)
    end
  end
end
