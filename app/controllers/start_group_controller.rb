class StartGroupController < ApplicationController
  before_action :redirect_to_dashboard

  def new
    group_with_creator
    render :new
  end

  def create
    if group.with_creator.errors.empty?
      StartGroupJob.perform_later(group_with_creator)
    else
      render :new
    end
  end

  private

  def group_with_creator
    @group_with_creator ||= GroupWithCreator.new(params)
  end

  def redirect_to_dashboard
    redirect_to_dashboard_path(start_group: true) if current_user_or_visitor.is_logged_in?
  end
end
