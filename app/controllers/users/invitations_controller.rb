class Users::InvitationsController < Devise::InvitationsController
  def create
    # TODO: Make this big method less ugly
    #   - use cancan
    #   - maybe move some of the code over to the User model?
    if params[:user][:group_id].present?
      group = Group.find params[:user].delete(:group_id)
      if can? :add_members, group
        email = params[:user][:email]
        existing_user = User.find_by_email(email)
        if existing_user.nil?
          @user = User.invite_and_notify! params[:user], current_inviter, group
          if @user.errors.empty?
            set_flash_message :notice, :send_instructions, :email => email
            respond_with @user, :location => group_url(group)
          else
            flash[:error] = t("error.invalid_email", which_email: email)
            respond_with_navigational(@user) { redirect_to group_url(group) }
          end
        else
          if existing_user.groups.include? group
            flash[:alert] = t("alert.duplicate_email", which_email: email)
          else
            membership = group.add_member! existing_user, current_user
            flash[:notice] = t("notice.email_added", which_email: email)
            # TODO: handle if mmember fails to be added
          end
          redirect_to group_url(group)
        end
      else
        flash[:error] = t("error.permission_to_invite")
        redirect_to group_url(group)
      end
    else
      email = params[:user][:email]
      @user = User.invite!(params[:user], current_user)
      if @user.errors.empty?
        set_flash_message :notice, :send_instructions, :email => email
        respond_with @user, :location => new_user_invitation_url
      else
        respond_with_navigational(@user) { render :new }
      end
    end
  end

  def after_accept_path_for(user)
    user.generate_username
    group = user.groups.first
    if group.nil?
      root_path
    else
      group_path(group)
    end
  end
end
