class Users::PasswordsController < Devise::PasswordsController

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      set_flash_message!(:notice, :updated)
      sign_in(resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def require_no_authentication
    # noop
  end
end
