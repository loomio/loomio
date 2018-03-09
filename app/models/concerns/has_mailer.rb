module HasMailer
  def mailer
    "#{self.class}Mailer".constantize
  end
end
