class StartGroupController < ApplicationController
  def new
    @errors = []
    @group = Group.new
    if current_user.present? && ENV['NEW_GROUPS_ON_ANGULAR']
      render :enable_angular
    else
      render :new
    end
  end

  def enable_angular
    current_user.update angular_ui_enabled: true
    redirect_to dashboard_path(start_group: true)
  end

  def create
    if user_signed_in?
      create_signed_in
    else
      create_signed_out
    end
  end

  def create_signed_in
    @group = Group.new(permitted_params.group)
    @errors = []
    @errors << 'group_name' if @group.name.blank?

    # check for valid name and email
    if @group.valid? and @errors.empty?
      @group = Group.new(permitted_params.group)
      @group.is_referral = true
      StartGroupService.start_group(@group)
      @group.add_admin!(current_user)
      redirect_to @group
    else
      render :new
    end
  end

  def create_signed_out
    @group = Group.new(permitted_params.group)
    @group.is_referral = false
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
