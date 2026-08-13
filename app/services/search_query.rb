class SearchQuery
  RESULT_LIMIT = 20
  FUZZY_TERM_LENGTH_MIN = 4
  FUZZY_TERM_LENGTH_MAX = 64
  FUZZY_TERMS_MAX = 8
  FUZZY_ALTERNATIVES_MAX = 3
  FUZZY_CANDIDATES_MAX = 200
  FUZZY_SIMILARITY_MIN = 0.25
  TOKEN_PATTERN = /[\p{L}\p{N}]+(?:['’_-][\p{L}\p{N}]+)*/

  def initialize(relation:, candidate_relation:, query:, order: nil)
    @relation = relation
    @candidate_relation = candidate_relation
    @query = query.to_s
    @order = order
  end

  def results
    exact = exact_relation.limit(RESULT_LIMIT).with_pg_search_highlight.to_a
    return exact unless fuzzy_search?

    if authored_order?
      fuzzy = fuzzy_results(limit: RESULT_LIMIT, excluding: exact.map(&:id))
      sort_by_authored_at(exact + fuzzy).first(RESULT_LIMIT)
    elsif exact.length < RESULT_LIMIT
      exact + fuzzy_results(limit: RESULT_LIMIT - exact.length, excluding: exact.map(&:id))
    else
      exact
    end
  end

  private

  attr_reader :relation, :candidate_relation, :query, :order

  def exact_relation
    apply_authored_order(PgSearch.multisearch(query).merge(relation))
  end

  def fuzzy_results(limit:, excluding:)
    PgSearch::Document.transaction(requires_new: true) do
      PgSearch::Document.connection.execute(
        "SET LOCAL pg_trgm.similarity_threshold = '#{FUZZY_SIMILARITY_MIN}'"
      )

      alternatives = fuzzy_alternatives
      next [] unless alternatives.values.any? { |words| words.length > 1 }

      fuzzy_relation(alternatives: alternatives, excluding: excluding).limit(limit).to_a
    end
  end

  def fuzzy_relation(alternatives:, excluding:)
    query_groups = terms.map { |term| tsquery_group(alternatives.fetch(term, [ term ])) }
    combined_query = query_groups.reduce { |left, right| Arel::Nodes::InfixOperation.new('||', left, right) }
    match_conditions = query_groups
      .map { |group| Arel::Nodes::InfixOperation.new('@@', documents[:ts_content], group) }
      .reduce(&:and)
    rank = query_groups
      .map { |group| Arel::Nodes::NamedFunction.new('ts_rank', [ documents[:ts_content], group ]) }
      .reduce { |left, right| Arel::Nodes::Addition.new(left, right) }
    highlight = Arel::Nodes::NamedFunction.new(
      'ts_headline',
      [
        Arel::Nodes.build_quoted('simple'),
        documents[:content],
        combined_query,
        Arel::Nodes.build_quoted('StartSel = "<b>", StopSel = "</b>"')
      ]
    )

    candidates = candidate_relation.where(match_conditions)
    candidates = candidates.where.not(id: excluding) if excluding.any?
    candidates = candidates.select(:id)
    candidates = if authored_order?
      apply_authored_order(candidates)
    else
      candidates.reorder(rank.desc, :id)
    end
    candidates = candidates.limit(FUZZY_CANDIDATES_MAX)
    candidate_ids = candidate_ids_without_anonymous_stances(candidates)

    rel = relation.where(id: candidate_ids)
    rel = rel.where.not(id: excluding) if excluding.any?
    rel = rel.select(documents[Arel.star], rank.as('fuzzy_score'), highlight.as('pg_search_highlight'))

    authored_order? ? apply_authored_order(rel) : rel.reorder(Arel.sql('fuzzy_score DESC'), :id)
  end

  def fuzzy_alternatives
    fuzzy = correction_candidates.group_by { |candidate| candidate['term'] }

    terms.index_with do |term|
      [ term, *fuzzy.fetch(term, []).map { |candidate| candidate['word'] } ].uniq
    end
  end

  def correction_candidates
    return [] if fuzzy_terms.empty?

    values = fuzzy_terms.map do |term|
      "(#{PgSearch::Document.connection.quote(term)})"
    end.join(', ')

    PgSearch::Document.connection.select_all(<<~SQL.squish).to_a
      SELECT input.term, candidate.word
      FROM (VALUES #{values}) AS input(term)
      CROSS JOIN LATERAL (
        SELECT word
        FROM pg_search_words
        WHERE word % input.term
          AND abs(length(word) - length(input.term)) <= 2
        ORDER BY similarity(word, input.term) * (1 + ln(document_count)) DESC
        LIMIT #{FUZZY_ALTERNATIVES_MAX}
      ) AS candidate
    SQL
  end

  def tsquery_group(words)
    alternatives = words.map do |word|
      Arel::Nodes::NamedFunction.new(
        'plainto_tsquery',
        [ Arel::Nodes.build_quoted('simple'), Arel::Nodes.build_quoted(word) ]
      )
    end

    Arel::Nodes::Grouping.new(
      alternatives.reduce { |left, right| Arel::Nodes::InfixOperation.new('||', left, right) }
    )
  end

  def documents
    PgSearch::Document.arel_table
  end

  def candidate_ids_without_anonymous_stances(candidates)
    rows = candidates.reselect(:id, :searchable_type, :poll_id).to_a
    stance_poll_ids = rows.filter_map { |row| row.poll_id if row.searchable_type == 'Stance' }
    anonymous_poll_ids = Poll.where(id: stance_poll_ids, anonymous: true).pluck(:id)

    rows.filter_map do |row|
      row.id unless row.searchable_type == 'Stance' && anonymous_poll_ids.include?(row.poll_id)
    end
  end

  def fuzzy_search?
    query.present? && !query.match?(/[!"()]/) && fuzzy_terms.any? && terms.length <= FUZZY_TERMS_MAX
  end

  def terms
    @terms ||= query.scan(TOKEN_PATTERN).map(&:downcase).uniq
  end

  def fuzzy_terms
    @fuzzy_terms ||= terms.select do |term|
      term.length.between?(FUZZY_TERM_LENGTH_MIN, FUZZY_TERM_LENGTH_MAX)
    end
  end

  def authored_order?
    %w[authored_at_asc authored_at_desc].include?(order)
  end

  def apply_authored_order(rel)
    case order
    when 'authored_at_asc'
      rel.reorder(authored_at: :asc)
    when 'authored_at_desc'
      rel.reorder(authored_at: :desc)
    else
      rel
    end
  end

  def sort_by_authored_at(documents)
    direction = order == 'authored_at_asc' ? 1 : -1
    documents.sort_by { |document| [ direction * document.authored_at.to_f, document.id ] }
  end
end
