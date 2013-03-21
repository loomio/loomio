class UsersController < BaseController
  before_filter :authenticate_user!, except: [:new, :create, :email_preferences, :update]
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback, only: [:email_preferences, :update]

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

  def email_preferences
    @user = @restricted_user || current_user
  end

  def update
    @user = @restricted_user || current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your settings have been updated."
      redirect_to :root
    else
      flash[:error] = "Your settings did not get updated."
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
      flash[:error] = "Unable to upload picture. Make sure the picture is under 1 MB and is a .jpeg, .png, or .gif file."
    end
    redirect_to :back
  end

  def set_avatar_kind
    @avatar_kind = params[:avatar_kind]
    current_user.avatar_kind = @avatar_kind
    current_user.save!
  end

  def set_markdown
    current_user.uses_markdown = params[:uses_markdown]
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

  private
  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
