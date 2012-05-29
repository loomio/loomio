class MembershipsController < BaseController
  load_and_authorize_resource

  #def update
    #@membership = Membership.find(params[:id])
    #if @membership.update_attributes(params[:membership])
      #flash[:notice] = "Membership approved."
      #redirect_to @membership.group
    #else
      #render :action => 'edit'
    #end
    #if params[:membership][:access_level] == 'member'
      #UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    #end
  #end

  def make_admin
    @membership = Membership.find(params[:id])
    @membership.access_level = "admin"
    @membership.save
    flash[:notice] = "#{@membership.user_name} has been made an admin."
    redirect_to @membership.group
  end

  def remove_admin
    @membership = Membership.find(params[:id])
    @membership.access_level = "member"
    @membership.save
    flash[:notice] = "#{@membership.user_name}'s admin rights have been removed."
    redirect_to @membership.group
  end

  def approve
    @membership = Membership.find(params[:id])
    flash[:notice] = "Membership approved"
    UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    # TODO: this logic should be moved out of the controller
    # and into the membership model (acts as state machine)
    @membership.access_level = "member"
    @membership.save
    redirect_to @membership.group
  end

  def create
    # NOTE (Jon):
    # I feel like this method/action should be renamed to
    # request_membership
    @group = Group.find(params[:membership][:group_id])
    @group.add_request!(current_user)
    if @group.can_be_viewed_by? current_user
      redirect_to group_url(@group)
    else
      flash[:notice] = "Membership requested."
      redirect_to root_url
    end
  end

  def destroy
    resource
    destroy! do |format|
      format.html do
        if @membership.access_level == "request"
          if current_user == @membership.user
            flash[:notice] = "Membership request canceled."
          else
            flash[:notice] = "Membership request ignored."
          end
        else
          if current_user == @membership.user
            flash[:notice] = "You have left #{@membership.group.name}."
          else
            flash[:notice] = "Member removed."
          end
        end
        redirect_to @membership.group
      end
    end
  end
end
