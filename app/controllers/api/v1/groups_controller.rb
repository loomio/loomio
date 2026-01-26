class Api::V1::GroupsController < Api::V1::RestfulController
  def token
    self.resource = load_and_authorize(:group, :invite_people)
    respond_with_resource scope: {include_token: true, exclude_types: ['membership', 'user']}
  end

  def suggest_handle
    render json: { handle: service.suggest_handle(name: params[:name], parent_handle: params[:parent_handle])  }
  end

  def reset_token
    self.resource = load_and_authorize(:group, :invite_people)
    resource.update(token: resource.class.generate_unique_secure_token)
    respond_with_resource scope: {include_token: true, exclude_types: ['membership', 'user']}
  end

  def show
    self.resource = load_and_authorize(:group)
    accept_pending_membership
    respond_with_resource
  end

  def index
    ids = params.fetch(:xids, '').split('x').map(&:to_i)
    if ids.length > 0
      instantiate_collection do |collection|
        collection = GroupQuery.visible_to(user: current_user, show_public: true).where(id: ids)
      end
    else
      order = case params[:order]
              when 'memberships_count'
                'groups.memberships_count DESC'
              when 'memberships_count_asc'
                'groups.memberships_count ASC'
              when 'created_at'
                'groups.created_at DESC'
              when 'created_at_asc'
                'groups.created_at ASC'
              else
                'groups.memberships_count DESC'
              end
      instantiate_collection { |collection| collection.search_for(params[:q]).order(order) }
    end
    respond_with_collection
  end

  def count_explore_results
    render json: { count: Queries::ExploreGroups.new.search_for(params[:q]).count }
  end

  def subgroups
    self.collection = load_and_authorize(:group).subgroups.select { |g| current_user.can? :show, g }
    respond_with_collection
  end

  def upload_photo
    ensure_photo_params
    service.update group: load_resource, actor: current_user, params: { params[:kind] => params[:file] }
    respond_with_resource
  end

  def export #json
    service.export(group: load_and_authorize(:group, :export), actor: current_user)
    render json: { success: :ok }
  end

  def export_csv
    group = load_and_authorize(:group, :export)
    GroupExportCsvWorker.perform_async(group.id, current_user.id)
    render json: { success: :ok }
  end

  private

  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

  def accessible_records
    Queries::ExploreGroups.new
  end
end
