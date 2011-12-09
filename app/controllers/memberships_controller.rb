class MembershipsController < BaseController
  def update
    # TODO:
    # - perhaps turn this into a state machine?
    # - make flash messages more specific
    def check_permission(membership, action)
      return false unless @membership.group.users.include? current_user
      user_access_level = @membership.group.memberships.
                          find_by_user_id(current_user.id).access_level
      other_member = @membership.access_level

      return true if user_access_level == 'admin'
      if user_access_level == 'member'
        return false if (other_member == 'admin' || other_member == 'member')
        return false if action == 'admin'
        return true if action == 'member'
        return true if action == 'request'
      end
      return false
    end

    resource
    if check_permission(@membership, params[:membership][:access_level])
      update! do |format|
        format.html { redirect_to @membership.group }
      end
      flash[:notice] = "Membership approved."
      if params[:membership][:access_level] =='member'
        UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
      end
    else
      flash[:error] = "You do not have significant priviledges to do that."
      redirect_to @membership.group
    end
  end

  def create
    build_resource
    @membership.user = current_user
    @membership.access_level = 'request'
    create! do |format|
      format.html { redirect_to groups_url }
    end
  end

  def destroy
    def check_permission(membership)
      return false unless @membership.group.users.include? current_user
      user_access_level = @membership.group.memberships.
                          find_by_user_id(current_user.id).access_level
      other_member = @membership.access_level

      if user_access_level == 'admin'
        return true if (other_member == 'request' || other_member == 'member')
      elsif user_access_level == 'member'
        return true if other_member == 'request'
      end
      return false
    end

    resource
    if check_permission(@membership)
      destroy! do |format|
        format.html do
          flash[:notice] = "Membership deleted."
          redirect_to @membership.group
        end
      end
    else
      flash[:error] = "You do not have significant priviledges to do that."
      redirect_to @membership.group
    end
  end
end
