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
      redirect_to send(:"#{model}_url", to), status: :moved_permanently
    else
      render :text => 'Not Found', :status => '404'
    end
  end
end
