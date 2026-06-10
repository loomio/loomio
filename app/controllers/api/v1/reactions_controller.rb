class Api::V1::ReactionsController < Api::V1::RestfulController
  alias :create :update
  REACTABLE_TYPES = {
    'Comment' => Comment,
    'Discussion' => Discussion,
    'Outcome' => Outcome,
    'Poll' => Poll,
    'Stance' => Stance
  }.freeze

  def index
    %w[comment_ids discussion_ids outcome_ids poll_ids stance_ids].each do |key|
      next unless params.has_key? key
      params[key] = params[key].split('x').map(&:to_i)
    end
    ReactionQuery.authorize!(user: current_user, params: params)
    self.collection = ReactionQuery.unsafe_where(params)
    respond_with_collection
  end

  private

  def accessible_records
    current_user.ability.authorize!(:show, reactable).reactions
  end

  def load_resource
    self.resource = case action_name
    when 'create', 'update' then resource_class.find_or_initialize_by(user: current_user, reactable: reactable)
    else super
    end
  end

  def reactable
    @reactable ||= begin
      type = reactable_params[:reactable_type].to_s.classify
      klass = REACTABLE_TYPES.fetch(type) { raise ActiveRecord::RecordNotFound }
      klass.find(reactable_params[:reactable_id])
    end
  end

  def reactable_params
    case action_name
    when 'create', 'update' then resource_params
    when 'index'            then params
    end
  end
end
