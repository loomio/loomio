class Api::V1::GroupsController < Api::V1::RestfulController
  ONBOARDING_PAIN_POINTS = %w[
    too_many_meetings
    confusing_email_or_chat
    decisions_get_stuck
    not_everyone_can_participate
    poor_decision_records
    few_voices_dominate
    unclear_who_decides
    voting_without_discussion
  ].freeze

  before_action :require_signed_in_user_for_explore, only: [:index, :count_explore_results]
  before_action :require_current_user, :enforce_trial_group_limit, only: [:create]

  def token
    self.resource = load_and_authorize(:group, :invite_people)
    respond_with_resource scope: {include_token: true, exclude_types: ['membership', 'user']}
  end

  def suggest_handle
    render json: { handle: service.suggest_handle(name: params[:name], parent_handle: params[:parent_handle])  }
  end

  def reset_token
    self.resource = load_and_authorize(:group, :invite_people)
    resource.update_columns(token: resource.class.generate_unique_secure_token, updated_at: Time.current)
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

  def remove_photo
    kind = params.require(:kind)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include?(kind)
    self.resource = load_and_authorize(:group, :update)
    resource.send(kind).purge_later
    respond_with_resource
  end

  def export #json
    service.export(group: load_and_authorize(:group, :export), actor: current_user)
    render json: { success: :ok }
  end

  def export_csv
    group = load_and_authorize(:group, :export)
    GroupExportCsvWorker.perform_later(group.id, current_user.id)
    render json: { success: :ok }
  end

  def export_html
    group = load_and_authorize(:group, :export)
    GroupExportHtmlWorker.perform_later(group.id, current_user.id)
    render json: { success: :ok }
  end

  def onboarding
    self.resource = load_and_authorize(:group, :update)
    info = (resource.info || {}).dup
    pain_points = Array(params[:pain_points]).map(&:to_s).select { |p| ONBOARDING_PAIN_POINTS.include?(p) }.uniq.first(2)
    info["pain_points"] = pain_points if pain_points.any?
    trial_intent = params[:trial_intent].to_s.strip.truncate(500)
    info["trial_intent"] = trial_intent if trial_intent.present?
    info["onboarding_completed_at"] = Time.current.iso8601

    attrs = { info: info }
    description = params[:description].to_s.strip
    if description.present?
      attrs[:description] = description
      attrs[:description_format] = "md"
    end

    resource.update!(attrs)
    EventBus.broadcast("group_onboarding_completed", resource, current_user)
    respond_with_resource
  end

  private

  def destroy_action
    service.warn_and_discard(group: resource, actor: current_user)
  end

  def enforce_trial_group_limit
    return if params.dig(:group, :parent_id).present?
    return if current_user.is_paying?
    return if current_user.created_at <= 7.days.ago
    trial_groups = current_user.created_groups.where(parent_id: nil)
                               .joins(:subscription).where(subscriptions: { plan: 'trial' })
    if trial_groups.exists?
      render json: { errors: { base: [t('errors.new_account_trial_group_limit')] } }, status: 429
    end
  end

  def require_signed_in_user_for_explore
    require_current_user if AppConfig.app_features[:restrict_explore_to_signed_in_users]
  end

  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

  def accessible_records
    Queries::ExploreGroups.new
  end
end
