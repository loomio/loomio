class GroupMailer < BaseMailer
  def destroy_warning(group_id, recipient_id, deletor_id)
    group = Group.find(group_id)
    recipient = User.find(recipient_id)
    deletor = User.find(deletor_id)

    component = Views::GroupMailer::DestroyWarning.new(
      group: group, recipient: recipient, deletor: deletor
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component,
               reply_to: ENV['SUPPORT_EMAIL']) {
      I18n.t("group_mailer.destroy_warning.subject")
    }
  end
end
