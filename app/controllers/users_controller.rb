class UsersController < BaseController
  def update
    update! {root_url}
  end
  def settings
    @user = current_user
  end
  
  def user_group_tags
    @user = User.find(params[:id])
    @tags = @user.group_tags

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags.collect {|tag| {:id => tag.id, :name => tag.name } } }
    end
  end
end
