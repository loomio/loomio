# frozen_string_literal: true

class Views::Email::Mailers::TaskMailer::TaskDueReminder < Views::Email::BaseLayout
  include PrettyUrlHelper

  def initialize(recipient:, task:)
    @recipient = recipient
    @task = task
  end

  def view_template
    days = @task.due_on - Date.today

    div do
      p do
        plain t(:"task_mailer.task_due_reminder.greeting",
          name: @recipient.name,
          due: days == 0 ? t(:"common.today") : t("common.in_x_days", x: days))
      end
      p { i { plain @task.name } }
      p { plain t(:"task_mailer.task_due_reminder.update_or_comment") }
      a(href: polymorphic_url(@task.record)) do
        plain t(:"task_mailer.task_due_reminder.view_task", site_name: AppConfig.theme[:site_name])
      end
    end
  end
end
