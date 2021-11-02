class TaskMailer < BaseMailer
  layout 'invite_people_mailer'

  def task_due_reminder(recipient, task)
    @recipient = recipient
    @task = task
    send_single_mail(
      locale: @recipient.locale,
      to: @recipient.name_and_email,
      subject_key: 'task_mailer.task_due_reminder.subject',
      subject_params: {name: @task.name},
    )
  end
end
