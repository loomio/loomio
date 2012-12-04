class UsersController < BaseController
  before_filter :authenticate_user!, except: [:new, :create, :email_preferences, :update]
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback, only: [:email_preferences, :update]

  def new
    @user = User.new
    unless Invitation.find_by_token(session[:invitation])
      redirect_to root_url
    end
  end

  def create
    @invitation = Invitation.find_by_token(session[:invitation])
    if @invitation && (not @invitation.accepted?)
      @user = User.new(params[:user])
      if @user.save
        @invitation.accept!(@user)
        sign_in @user
        group = Group.find(@invitation.group_id)
        discussion = group.discussions.where(:title => "Example Discussion: Welcome and introduction to Loomio!").first
        if discussion
          redirect_to discussion_path(discussion.id)
        else
          redirect_to group_path(group.id)
        end
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
    current_user.avatar_kind = params[:avatar_kind]
    current_user.save
    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.js {}
    end
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
