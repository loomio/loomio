class Users::InvitationsController < Devise::InvitationsController
  def create
    group = Group.find params[:user].delete(:group_id)
    if group.has_admin_user?(current_user)
      email = params[:user][:email].downcase
      existing_user = User.where('LOWER(email) LIKE ?', email).first
      if existing_user.nil?
        @user = User.invite! params[:user], current_inviter
        group.add_member! @user
        if @user.errors.empty?
          set_flash_message :notice, :send_instructions, :email => email
          respond_with @user, :location => after_invite_path_for(@user)
        else
          respond_with_navigational(@user) { render :new }
        end
      else
        if existing_user.groups.include? group
          flash[:alert] = "#{email} is already in the group."
        else
          flash[:notice] = "#{email} has been added to the group."
          group.add_member! existing_user
          UserMailer.added_to_group(existing_user, group).deliver
        end
        redirect_to after_invite_path_for(existing_user)
      end
    else
      flash[:error] = "Only group admins can invite new members."
      redirect_to group_url(group)
    end
  end

  def after_invite_path_for(user)
    group = user.groups.first
    group_path(group) + "#users"
  end

  def after_accept_path_for(user)
    group = user.groups.first
    if group.nil?
      root_path
    else
      group_path(group)
    end
  end
end
