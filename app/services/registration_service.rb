class RegistrationService
  Result = Data.define(:status, :user)

  # Registration creates or reuses a provisional account. Authentication proof
  # is resolved by the controller because it belongs to the current request and
  # session; this service returns the next state without performing HTTP, email,
  # or session side effects.
  def self.create(email:, email_control_proved:)
    user = UserService.create(params: { email: email })

    status = if user.errors.any?
      :invalid
    elsif !email_control_proved
      :send_code
    elsif user.incomplete?
      :incomplete
    else
      :sign_in
    end

    Result.new(status:, user:)
  rescue UserService::EmailTakenError
    Result.new(status: :send_code, user: User.active.find_by(email: email))
  end
end
