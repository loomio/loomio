class StartGroupController < ApplicationController

  def new
    @errors = []
    @group = Group.new
    if !current_user_or_visitor.is_logged_in?
      render :new
    else
      redirect_to dashboard_path(start_group: true)
    end
  end

  def create
    # TODO: move these validations into the group model... where they should already be really.
    @group = Group.new(permitted_params.group, is_referral: false)
    @email = params[:email]
    @name =  params[:name]
    @errors = []
    @errors << 'name' if @name.blank?
    @errors << 'email' unless /^[^@]+@[^@]+\.[^@]+$/.match @email
    @errors << 'group_name' if @group.name.blank?

    # check for valid name and email
    if @group.valid? and @errors.empty?
      StartGroupService.start_group(@group)
      StartGroupService.invite_admin_to_group(group: @group,
                                              name: @name,
                                              email: @email)
    else
      render :new
    end
  end
end
