class GroupsController < GroupBaseController
  # TODO Jon: some of the code for tagging in this controller can probably
  # be moved into the model

  load_and_authorize_resource except: :show
  before_filter :check_group_read_permissions, only: :show

  def create
    build_resource
    @group.add_admin! current_user
    create!
  end

  # CUSTOM CONTROLLER ACTIONS

  def invite_member
    @group = Group.find(params[:id])
    @user = User.new
  end

  def request_membership
    @group = Group.find(params[:id])
    @membership = Membership.new
  end

  def add_user_tag
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    new_tags = user.group_tags_from(group).join(",") + "," + params[:tag]
    group.set_user_tags user, new_tags
    #TODO AC: tests fail without this redirect, open to suggestions here
    redirect_to groups_url
  end

  def delete_user_tag
    group = Group.find(params[:id])
    user = User.find(params[:user_id])
    group.delete_user_tag user, params[:tag]
    #TODO AC: tests fail without this redirect, open to suggestions here
    redirect_to groups_url
  end

  def group_tags
    group = Group.find(params[:id])
    tags = group.owned_tags.where("tags.name LIKE ?", "%#{params[:q]}%")

    respond_to do |format|
      format.json { render json: tags.collect {|tag| {:id => tag.id, :name => tag.name } } }
    end
  end

  def user_group_tags
    group = Group.find params[:id]
    user = User.find params[:user_id]
    tags = group.get_user_tags user

    respond_to do |format|
      format.json { render json: tags.collect {|tag| {:id => tag.id, :name => tag.name } } }
    end
  end

  private

    def group
      resource
    end
end
