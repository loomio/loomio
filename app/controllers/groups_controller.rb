class GroupsController < GroupBaseController
  before_filter :authenticate_user!, except: :show

  before_filter :load_resource_by_key, :except => [:create, :new]
  authorize_resource except: :create

  before_filter :ensure_group_is_setup, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
  end

  #for new subgroup form
  def add_subgroup
    parent = Group.published.find(params[:id])
    @subgroup = Group.new(:parent => parent, privacy: parent.privacy)
    @subgroup.members_invitable_by = parent.members_invitable_by
  end

  def create
    @group = Group.new(permitted_params.group)
    authorize!(:create, @group)
    @group.mark_as_setup!
    if @group.save
      @group.add_admin! current_user
      flash[:success] = t("success.group_created")
      redirect_to @group
    elsif @group.is_a_subgroup?
        @subgroup = @group
        render 'groups/add_subgroup'
    else
      render 'form'
    end
  end

  def new
    @group = Group.new
    @group.payment_plan = 'undetermined'
  end

  def update
    if @group.update_attributes(permitted_params.group)
      if @group.is_hidden?
        @group.discussions.update_all(private: true)
      end
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
    @discussions_with_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).
                                                            with_open_motions.
                                                            order('motions.closing_at ASC').
                                                            preload({:current_motion => :discussion}, {:group => :parent})

    @discussions_without_open_motions = GroupDiscussionsViewer.for(group: @group, user: current_user).
                                                            without_open_motions.
                                                            order('last_comment_at DESC').
                                                            preload(:current_motion, {:group => :parent}).
                                                            page(params[:page]).per(20)

    build_discussion_index_caches

    assign_meta_data
  end

  def edit
  end

  def archive
    @group.archive!
    flash[:success] = t("success.group_archived")
    redirect_to root_path
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
    @description = params[:description]
    @group.description = @description
    @group.save!
  end

  def members_autocomplete
    users = @group.users.where('username ilike :term or name ilike :term ', {term: "%#{params[:q]}%"})
    render json: users.map{|u| {name: "#{u.name} #{u.username}", username: u.username, real_name: u.name} }
  end

  private

    def load_resource_by_key
      group
      raise ActiveRecord::RecordNotFound if @group.model.blank?
    end

    def ensure_group_is_setup
      if user_signed_in? && @group.admins.include?(current_user)
        unless @group.is_setup? || @group.is_a_subgroup?
          redirect_to setup_group_path(@group)
        end
      end
    end

    def assign_meta_data
      if @group.privacy == :public
        @meta_title = @group.name
        @meta_description = @group.description
      end
    end
end
