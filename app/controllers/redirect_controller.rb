class RedirectController < ApplicationController
  def subdomain
    redirect model: :group, to: Group.find_by!(handle: request.subdomain)
  end

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
    redirect_to send(:"#{model}_url", to, subdomain: ENV['DEFAULT_SUBDOMAIN']), status: :moved_permanently
  end
end
