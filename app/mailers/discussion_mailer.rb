class DiscussionMailer < BaseMailer
  def new_discussion_created(discussion, user)
    @user = user
    @discussion = discussion
    @group = discussion.group
    @rendered_discussion_description = render_rich_text(discussion.description, discussion.uses_markdown)
    locale = best_locale(user.language_preference, discussion.author.language_preference)
    I18n.with_locale(locale) do
      mail  to: user.email,
            reply_to: discussion.author_email,
            subject: "#{email_subject_prefix(@group.full_name)} " + t("email.create_discussion.subject", which: @discussion.title)
    end
  end
end
