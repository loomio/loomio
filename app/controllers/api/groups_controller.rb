class API::GroupsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key
  load_resource only: [:upload_photo, :use_gift_subscription], find_by: :key

  def archive
    load_resource
    GroupService.archive(group: @group, actor: current_user)
    respond_with_resource
  end

  def subgroups
    load_and_authorize :group
    @groups = @group.subgroups.select{|g| can? :show, g }
    respond_with_collection
  end

  def use_gift_subscription
    if SubscriptionService.available?
      SubscriptionService.new(resource, current_user).start_gift!
      respond_with_resource
    else
      respond_with_standard_error ActionController::BadRequest, 400
    end
  end

  def upload_photo
    ensure_photo_params
    service.update group: resource, actor: current_user, params: { params[:kind] => params[:file] }
    respond_with_resource
  end

  private

  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

end
