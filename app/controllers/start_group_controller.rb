class StartGroupController < ApplicationController
  before_action :redirect_to_dashboard

  def new
    group_with_creator
    render :new
  end

  def create
    if group_with_creator.errors.empty?
      GroupService.create(group: group_with_creator.group, actor: group_with_creator.creator)
    else
      render :new
    end
  end

  private

  def group_with_creator
    @group_with_creator ||= GroupWithCreator.new(params)
  end

  def redirect_to_dashboard
    redirect_to dashboard_path(start_group: true) if current_user.is_logged_in?
  end
end
