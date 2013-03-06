class WocMailer < ActionMailer::Base
  default from: "woc_requests@loomio.org"

  def send_request(name, email, robot_trap)
    @name = name
    @email = email
    @robot_trap = robot_trap
    subject = robot_trap.present? ? "[Possible spam] " : ""
    subject += "WOC Request: #{@name} - #{@email}"
    mail(
      to: "ben@loomio.org",
      reply_to: "contact@loomio.org",
      subject: subject)
  end
end
