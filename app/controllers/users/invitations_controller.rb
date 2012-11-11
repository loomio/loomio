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
            Event.user_added_to_group!(@user.memberships.first)
            respond_with @user, :location => group_url(group)
          else
            # Jon: Sorry I know this is bad code. The validations should
            # be happening the standard rails way (with client-side
            # validations). But it's going to be a pain in the ass to code
            # and I'd rather save that work for when we refactor this method.
            # (Which I should probably stop putting off...)
            flash[:error] = "#{email} was not invited. The email address given seems invalid."
            respond_with_navigational(@user) { redirect_to group_url(group) }
          end
        else
          if existing_user.groups.include? group
            flash[:alert] = "#{email} is already in the group."
          else
            flash[:notice] = "#{email} has been added to the group."
            # TODO: handle if mmember fails to be added
            membership = group.add_member! existing_user, current_user
            Event.user_added_to_group!(membership)
          end
          redirect_to group_url(group)
        end
      else
        flash[:error] = "You do not have permission to invite new members."
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
    group = user.groups.first
    if group.nil?
      root_path
    else
      group_path(group)
    end
  end
end
