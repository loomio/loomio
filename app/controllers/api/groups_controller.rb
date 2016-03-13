class API::GroupsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key
  load_resource only: [:upload_photo, :use_gift_subscription, :archive], find_by: :key

  named_action :archive

  def subgroups
    instantiate_collection { load_and_authorize(:group).subgroups.select{|g| can? :show, g } }
    respond_with_collection
  end

  def use_gift_subscription
    respond_with_standard_error ActionController::BadRequest, 400 unless SubscriptionService.available?
    SubscriptionService.new(resource, current_user).start_gift!
    respond_with_resource
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
