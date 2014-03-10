class DiscussionMailer < BaseMailer
  def new_discussion_created(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'
    locale = best_locale(user.locale, discussion.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: "#{discussion.author.name} <noreply@loomio.org>",
            reply_to: discussion.author_name_and_email,
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_discussion.subject", which: @discussion.title)
    end
  end
end
