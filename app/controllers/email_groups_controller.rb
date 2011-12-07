class EmailGroupsController < BaseController
  actions :new, :create
  def new
  end
  def create
    @group = current_user.groups.find params[:group_id]
    @message = params[:message]
    email_addresses = @group.users.map{|m| m.email }
    GroupMailer.email_group(email_addresses, @message, @group).deliver!
    flash[:notice] = 'group spammed successfully'
    redirect_to root_url
  end
end
