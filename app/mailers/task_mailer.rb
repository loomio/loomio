class TaskMailer < BaseMailer
  def task_due_reminder(recipient, task)
    component = Views::Email::Mailers::TaskMailer::TaskDueReminder.new(
      recipient: recipient, task: task
    )

    send_email(to: recipient.name_and_email, locale: recipient.locale, component: component) {
      I18n.t("task_mailer.task_due_reminder.subject", name: task.name)
    }
  end
end
