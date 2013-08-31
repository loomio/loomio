class GroupsController < GroupBaseController
  load_and_authorize_resource except: :create
  before_filter :authenticate_user!, except: :show
  before_filter :ensure_group_is_setup, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
  end

  #for new subgroup form
  def add_subgroup
    @parent = Group.find(params[:id])
    @subgroup = Group.new(:parent => @parent)
    @subgroup.members_invitable_by = @parent.members_invitable_by
  end

  #for create group
  def create
    @group = Group.new(permitted_params.group)
    authorize!(:create, @group)
    if @group.save
      @group.add_admin! current_user
      flash[:success] = t("success.group_created")
      redirect_to @group
    else
      render 'groups/new'
    end
  end

  def update
    if @group.update_attributes(permitted_params.group)
      flash[:notice] = 'Group was successfully updated.'
      redirect_to @group
    else
      render :edit
    end
  end

  def show
    @group = GroupDecorator.new @group
    @subgroups = @group.subgroups.all.select{|g| can?(:show, g) }
    @discussions = GroupDiscussionsViewer.for(group: @group, user: current_user)
    @discussion = Discussion.new(group_id: @group.id)
    assign_meta_data
  end

  def edit
    @group = GroupDecorator.new(Group.find(params[:id]))
  end

  def archive
    @group.archive!
    flash[:success] = t("success.group_archived")
    redirect_to root_path
  end


  def add_members
    # params.each_key do |key|
    #   if key =~ /user_/
    #     user = User.find(key[5..-1])
    #     @group.add_member!(user, current_user)
    #   end
    # end

    user_ids = []
    params.each_key do |key|
      user_ids << key[5..-1] if key =~ /user_/
    end
    users_to_add = @group.parent.members.where(id: user_ids)
    memberships = @group.add_members!(users_to_add)
    memberships.each { |membership| Events::UserAddedToGroup.publish!(membership) }

    flash[:success] = t("success.members_added")
    redirect_to @group
  end

  def hide_next_steps
    @group.update_attribute(:next_steps_completed, true)
  end

  def new_motion
    @group = GroupDecorator.new Group.find(params[:id])
    @motion = Motion.new
  end

  def email_members
    subject = params[:group_email_subject]
    body = params[:group_email_body]
    GroupMailer.delay.deliver_group_email(@group, current_user, subject, body)
    flash[:success] = t("success.emails_sending")
    redirect_to @group
  end

  def edit_description
    @group = Group.find(params[:id])
    @description = params[:description]
    @group.description = @description
    @group.save!
  end

  def get_members
    @users = @group.users
    if (params[:pre].present?)
      @users = @users.select { |user| user.username =~ /#{params[:pre]}/ }
    end
    respond_to do |format|
      format.json { render 'groups/users' }
    end
  end

  def edit_privacy
    @group = Group.find(params[:id])
    @viewable_by = params[:viewable_by]
    @group.viewable_by = @viewable_by
    @group.save!
  end

  private
    def ensure_group_is_setup
      if user_signed_in? && @group.admins.include?(current_user)
        unless @group.is_setup? || @group.is_a_subgroup?
          redirect_to setup_group_path(@group)
        end
      end
    end

    def assign_meta_data
      if @group.viewable_by == :everyone
        @meta_title = @group.name
        @meta_description = @group.description
      end
    end
end
