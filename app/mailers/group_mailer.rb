class GroupMailer < ActionMailer::Base
  default from: "noreply@example.com"
  def email_group(email_addresses, message, group)
    mail to: email_addresses, subject: "[Tautoko: #{group.name}] announcement"
  end
end
