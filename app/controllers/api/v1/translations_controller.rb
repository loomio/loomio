class Api::V1::TranslationsController < Api::V1::RestfulController
  before_action :require_current_user

  def inline
    unless TranslationService.supported_locale?(params[:to])
      render json: { error: 'unsupported locale' }, status: :unprocessable_entity
      return
    end

    model = load_and_authorize(params[:model])
    authorize_stance_reason!(model)

    if self.resource = TranslationService.cached(model: model, to: params[:to])
      respond_with_resource
      return
    end

    unless TranslationService.available?
      render json: { error: 'translation unavailable' }, status: :service_unavailable
      return
    end

    unless ThrottleService.can?(key: 'Translations', id: current_user.id, max: 50, per: 'hour')
      render json: { error: 'Rate limit exceeded' }, status: 429
      return
    end

    self.resource = service.create(model: model, to: params[:to])
    respond_with_resource
  end

  private

  def authorize_stance_reason!(model)
    return unless model.is_a?(Stance)

    voted = model.poll.stances.latest.decided.exists?(participant_id: current_user.id)
    raise CanCan::AccessDenied unless model.reason_visible_to?(user_id: current_user.id, voted: voted)
  end

  def count_collection
    false
  end
end
