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
    @discussion = Discussion.new(group_id: @group.id)
    @discussions_with_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).with_open_motions.order('motions.closing_at ASC')
    @discussions_without_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).without_open_motions.order('created_at DESC').page(params[:page]).per(20)
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
    user_ids = []
    params.each_key do |key|
      user_ids << key[5..-1] if key =~ /user_/
    end
    users_to_add = @group.parent.members.where(id: user_ids)
    memberships = @group.add_members!(users_to_add, current_user)
    memberships.each { |membership| Events::UserAddedToGroup.publish!(membership, current_user) }

    flash[:success] = t("success.members_added")
    redirect_to @group
  end

  def hide_next_steps
    @group.update_attribute(:next_steps_completed, true)
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

  def members_autocomplete
    users = @group.users.where('username ilike :term or name ilike :term ', {term: "%#{params[:q]}%"})
    render json: users.map{|u| {name: "#{u.name} #{u.username}", username: u.username, real_name: u.name} }
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
