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
        sign_in @user
        redirect_to group_path(@group_request.group)
      else
        render :action => "new"
      end
    else
      redirect_to root_url
    end
  end

  def show
    @user = User.find(params[:id])
    unless current_user.in_same_group_as?(@user)
      flash[:error] = t("error.cant_view_member_profile")
      redirect_to root_url
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      set_locale
      flash[:notice] = t("notice.settings_updated")
      redirect_to root_url
    else
      flash[:error] = t("error.settings_not_updated")
      redirect_to user_settings_url
    end
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
    redirect_to user_settings_url
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
    head :ok
  end
end
