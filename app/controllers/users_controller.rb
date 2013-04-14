class UsersController < BaseController
  before_filter :authenticate_user!, except: [:new, :create]

  def new
    @user = User.new
    unless GroupRequest.find_by_token(session[:start_new_group_token])
      redirect_to root_url
    end
  end

  def create
    @group_request = GroupRequest.find_by_token(session[:start_new_group_token])
    if @group_request && (not @group_request.accepted?)
      @user = User.new(params[:user])
      if @user.save
        @user.generate_username
        sign_in @user
        redirect_to group_path(@group_request.group)
      else
        render :action => "new"
      end
    else
      redirect_to root_url
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = t("notice.settings_updated")
      redirect_to :root
    else
      flash[:error] = t("error.settings_not_updated")
      redirect_to :back
    end
  end

  def edit_name
    @user_name = params[:user_name]
    current_user.name = @user_name
    current_user.save!
  end

  def upload_new_avatar
    new_uploaded_avatar = params[:uploaded_avatar]

    if new_uploaded_avatar
      current_user.avatar_kind = "uploaded"
      current_user.uploaded_avatar = new_uploaded_avatar
    end

    unless current_user.save
      flash[:error] = t("error.image_upload_fail")
    end
    redirect_to :back
  end

  def set_avatar_kind
    @avatar_kind = params[:avatar_kind]
    current_user.avatar_kind = @avatar_kind
    current_user.save!
  end

  def settings
    @user = current_user
  end

  def dismiss_system_notice
    current_user.has_read_system_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_dashboard_notice
    current_user.has_read_dashboard_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_group_notice
    current_user.has_read_group_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_discussion_notice
    current_user.has_read_discussion_notice = true
    current_user.save!
    redirect_to :back
  end
end
