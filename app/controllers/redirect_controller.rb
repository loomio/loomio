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
    redirect_to send(:"#{model}_url", to, status: :moved_permanently)
  end
end
