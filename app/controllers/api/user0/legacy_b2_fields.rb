# Requests through /api/b2 keep the poll field and value names from before the
# user0 rename. The adapter only renames keys and values: serializers still
# decide which fields a caller may see, so hidden participation stays hidden.
module Api::User0::LegacyB2Fields
  extend ActiveSupport::Concern

  POLL_FIELDS = {
    'vote_count_eligible' => 'voters_count',
    'vote_count_cast' => 'decided_voters_count',
    'vote_count_uncast' => 'undecided_voters_count',
    'participation_pct' => 'cast_stances_pct',
    'scores_by_option' => 'stance_counts',
    'quorum_threshold' => 'quorum_count',
    'quorum_shortfall' => 'quorum_votes_required',
    'score_min' => 'min_score',
    'score_max' => 'max_score',
    'choice_count_min' => 'minimum_stance_choices',
    'choice_count_max' => 'maximum_stance_choices',
    'points_per_voter' => 'dots_per_person'
  }.freeze

  RESULT_FIELDS = {
    'vote_count' => 'voter_count',
    'scores_by_voter' => 'voter_scores'
  }.freeze

  # Poll settings b2 clients may still send under their old names.
  POLL_PARAMS = POLL_FIELDS.slice('score_min', 'score_max', 'choice_count_min', 'choice_count_max', 'points_per_voter').invert.freeze

  AUDIENCES = {
    'decided_voters' => 'voters_cast',
    'undecided_voters' => 'voters_uncast'
  }.freeze

  included do
    before_action :translate_legacy_b2_params, if: :legacy_b2_request?
    after_action :translate_legacy_b2_response, if: :legacy_b2_request?
  end

  private

  def legacy_b2_request?
    request.path.start_with?('/api/b2/')
  end

  def translate_legacy_b2_params
    [params, params[:poll]].each do |values|
      next unless values.respond_to?(:key?)

      POLL_PARAMS.each { |legacy, current| values[current] = values.delete(legacy) if values.key?(legacy) }
      values[:notify_on_closing_soon] = 'voters_uncast' if values[:notify_on_closing_soon] == 'undecided_voters'
      values[:recipient_audience] = AUDIENCES[values[:recipient_audience]] if AUDIENCES.key?(values[:recipient_audience])
    end
  end

  def translate_legacy_b2_response
    return unless response.media_type == 'application/json' && response.body.present?

    body = JSON.parse(response.body)
    return unless body.is_a?(Hash) && body['polls'].is_a?(Array)

    body['polls'].each do |poll|
      POLL_FIELDS.each { |current, legacy| poll[legacy] = poll.delete(current) if poll.key?(current) }
      Array(poll['results']).each do |result|
        RESULT_FIELDS.each { |current, legacy| result[legacy] = result.delete(current) if result.key?(current) }
      end
      poll['notify_on_closing_soon'] = 'undecided_voters' if poll['notify_on_closing_soon'] == 'voters_uncast'
    end
    response.body = body.to_json
  end
end
