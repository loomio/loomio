class Users::PasswordsController < Devise::PasswordsController
  private

  def require_no_authentication
    # noop
  end
end
