class DiscussionMailer < BaseMailer
  def new_discussion_created(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    @utm_hash = UTM_EMAIL.merge utm_source: 'new_discussion_created'
    locale = locale_fallback(user.locale, discussion.author.locale)
    I18n.with_locale(locale) do
      mail  to: user.email,
            from: from_user_via_loomio(discussion.author),
            reply_to: reply_to_address(discussion: discussion, user: user),
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_discussion.subject", which: @discussion.title)
    end
  end
end
