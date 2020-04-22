class SearchVector < ApplicationRecord

  WEIGHT_VALUES = [
    ENV.fetch('SEARCH_WEIGHT_A', 1.0),
    ENV.fetch('SEARCH_WEIGHT_B', 0.3),
    ENV.fetch('SEARCH_WEIGHT_C', 0.1),
    ENV.fetch('SEARCH_WEIGHT_D', 0.03)
  ].reverse.freeze

  RECENCY_VALUES = [
    ENV.fetch('SEARCH_RECENCY_A', 4.0),
    ENV.fetch('SEARCH_RECENCY_B', 0.8),
    ENV.fetch('SEARCH_RECENCY_C', 0.5),
    ENV.fetch('SEARCH_RECENCY_D', 0.1)
  ].freeze

  DISCUSSION_FIELD_WEIGHTS = {
    'discussions.title'        => :A,
    'poll_titles'              => :B,
    'discussions.description'  => :C,
    'poll_details'             => :C,
    'comment_bodies'           => :D
  }.freeze

  belongs_to :discussion, dependent: :destroy
  self.table_name = 'discussion_search_vectors'

  validates :discussion, presence: true
  validates :search_vector, presence: true

  scope :search_for, ->(query, user, opts = {}) do
    DiscussionQuery.visible_to(chain: search_without_privacy!(query),
      user: user,
      group_ids: user.group_ids,
    ).offset(opts.fetch(:from, 0)).limit(opts.fetch(:per, 10))
  end

  scope :search_without_privacy!, ->(query) do
    query = connection.quote(query)

    joins(discussion: :group)
   .select(:discussion_id, :search_vector, 'groups.name as result_group_name', 'groups.id as result_group_id')
   .select("ts_rank_cd('{#{WEIGHT_VALUES.join(',')}}', search_vector, plainto_tsquery(#{query})) * #{recency_multiplier} as rank")
   .where("search_vector @@ plainto_tsquery(#{query})")
   .order('rank DESC')
  end

  def self.recency_multiplier
    "CASE WHEN date_part('day', current_date - last_activity_at) BETWEEN 0 AND 7   THEN #{RECENCY_VALUES[0]}
          WHEN date_part('day', current_date - last_activity_at) BETWEEN 7 AND 21  THEN #{RECENCY_VALUES[1]}
          WHEN date_part('day', current_date - last_activity_at) BETWEEN 21 AND 42 THEN #{RECENCY_VALUES[2]}
          ELSE                                                                          #{RECENCY_VALUES[3]}
     END"
  end


  def update_search_vector
    tap { |search_vector| build_search_vector && save }
  end

  private

  def build_search_vector
    vector = self.class.connection.execute(vector_for_discussion.to_sql).first || {}
    self.search_vector = vector.fetch('search_vector', nil)
  end

  def vector_for_discussion
    Discussion.select(self.class.discussion_field_weights + ' as search_vector')
              .joins("LEFT JOIN (#{vector_for_polls.to_sql})    polls ON TRUE")
              .joins("LEFT JOIN (#{vector_for_comments.to_sql}) comments ON TRUE")
              .where(id: self.discussion_id)
  end

  def vector_for_polls
    Poll.select("string_agg(title, ',')                AS poll_titles")
        .select("LEFT(string_agg(details, ','), 10000) AS poll_details")
        .where(discussion_id: self.discussion_id)
  end

  def vector_for_comments
    Comment.select("LEFT(string_agg(body, ','), 20000) AS comment_bodies")
           .where(discussion_id: self.discussion_id)
  end

  def self.discussion_field_weights
    DISCUSSION_FIELD_WEIGHTS.map { |field, weight| "setweight(to_tsvector(coalesce(#{field}, '')), '#{weight}')" }.join ' || '
  end

end
