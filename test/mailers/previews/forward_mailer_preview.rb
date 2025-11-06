# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/forward_mailer
class ForwardMailerPreview < ActionMailer::Preview
  # Preview this email at:
  # /rails/mailers/forward_mailer/bounce
  def bounce
    ForwardMailer.bounce(to: 'user@example.com')
  end


end