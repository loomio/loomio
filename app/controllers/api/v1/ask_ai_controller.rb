# frozen_string_literal: true

class Api::V1::AskAiController < Api::V1::RestfulController
  before_action :require_current_user

  # POST /api/v1/ask_ai
  # Params:
  # - discussion_id: Integer (required)
  # - prompt: String (optional)
  #
  # Response:
  # {
  #   "answer": "string",
  #   "model": "model-name",
  #   "usage": {...},      # if available from OpenAI
  #   "id": "chatcmpl-..." # if available from OpenAI
  # }
  def create
    prompt = params[:prompt].presence

    target = nil
    if params[:discussion_id].present?
      discussion = Discussion.find(params[:discussion_id])
      current_user.ability.authorize!(:show, discussion)
      target = { discussion_id: discussion.id }
    elsif params[:group_id].present?
      group = Group.find(params[:group_id])
      current_user.ability.authorize!(:show, group)
      target = { group_id: group.id }
    elsif params[:poll_id].present?
      poll = Poll.find(params[:poll_id])
      current_user.ability.authorize!(:show, poll)
      target = { poll_id: poll.id }
    elsif params[:outcome_id].present?
      outcome = Outcome.find(params[:outcome_id])
      current_user.ability.authorize!(:show, outcome)
      target = { outcome_id: outcome.id }
    else
      render json: { error: 'missing_target' }, status: :unprocessable_entity and return
    end

    ThrottleService.limit!(key: 'ASK_AI', id: current_user.id, max: 20, inc: 1, per: 'hour')

    result = AskAiService.ask(
      **target,
      prompt: prompt,
      actor: current_user
    )

    render json: result, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'not_found' }, status: :not_found
  rescue CanCan::AccessDenied
    render json: { error: 'forbidden' }, status: :forbidden
  rescue AskAiService::MissingApiKeyError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue ThrottleService::LimitReached
    render json: { error: 'too_many_requests' }, status: :too_many_requests
  rescue => e
    Rails.logger.error("AskAiController#create error: #{e.class} #{e.message}")
    render json: { error: 'ask_ai_failed' }, status: :bad_gateway
  end

  # POST /api/v1/ask_ai/options
  # Params:
  # - discussion_id: Integer (required)
  # - max: Integer (optional, default: 30)
  #
  # Response:
  # {
  #   "options": [ {"name": "...", "meaning": "..."}, ... ]
  # }
  def options
    discussion_id = params[:discussion_id].presence
    unless discussion_id
      render json: { error: 'missing_target' }, status: :unprocessable_entity and return
    end

    discussion = Discussion.find(discussion_id)
    current_user.ability.authorize!(:show, discussion)

    ThrottleService.limit!(key: 'ASK_AI', id: current_user.id, max: 20, inc: 1, per: 'hour')

    max = params[:max].presence || 30
    result = AskAiService.extract_poll_options(
      discussion_id: discussion.id,
      max: max.to_i,
      actor: current_user
    )

    render json: result, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'not_found' }, status: :not_found
  rescue CanCan::AccessDenied
    render json: { error: 'forbidden' }, status: :forbidden
  rescue AskAiService::MissingApiKeyError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue ThrottleService::LimitReached
    render json: { error: 'too_many_requests' }, status: :too_many_requests
  rescue => e
    Rails.logger.error("AskAiController#options error: #{e.class} #{e.message}")
    render json: { error: 'ask_ai_failed' }, status: :bad_gateway
  end

  # POST /api/v1/ask_ai/scaffold
  # Params:
  # - discussion_id: Integer (required)
  # - prompt: String (optional)
  # - max: Integer (optional, default: 30)
  #
  # Response:
  # {
  #   "title": "string",
  #   "details": "string or null",
  #   "options": [ {"name":"...", "meaning":"..."}, ... ]
  # }
  def scaffold
    discussion_id = params[:discussion_id].presence
    unless discussion_id
      render json: { error: 'missing_target' }, status: :unprocessable_entity and return
    end

    discussion = Discussion.find(discussion_id)
    current_user.ability.authorize!(:show, discussion)

    ThrottleService.limit!(key: 'ASK_AI', id: current_user.id, max: 20, inc: 1, per: 'hour')

    result = AskAiService.scaffold_poll(
      discussion_id: discussion.id,
      prompt: params[:prompt].presence,
      max: (params[:max].presence || 30).to_i,
      actor: current_user
    )

    render json: result, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'not_found' }, status: :not_found
  rescue CanCan::AccessDenied
    render json: { error: 'forbidden' }, status: :forbidden
  rescue AskAiService::MissingApiKeyError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue ThrottleService::LimitReached
    render json: { error: 'too_many_requests' }, status: :too_many_requests
  rescue => e
    Rails.logger.error("AskAiController#scaffold error: #{e.class} #{e.message}")
    render json: { error: 'ask_ai_failed' }, status: :bad_gateway
  end
end
