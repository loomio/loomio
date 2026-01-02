class RedirectController < ApplicationController
  def group
    redirect
  end

  def discussion
    redirect
  end

  def poll
    redirect
  end

  private

  def redirect(model: action_name, to: ModelLocator.new(model, params).locate)
    if to.present?
      redirect_to send(:"#{model}_path", to), status: :moved_permanently
    else
      respond_with_error 404
    end
  end
end
