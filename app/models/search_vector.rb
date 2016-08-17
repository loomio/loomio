class SearchVector < ActiveRecord::Base

  WEIGHT_VALUES = [
    1.0,   # A
    0.3,  # B
    0.1,  # C
    0.03 # D
  ].reverse.freeze

  DISCUSSION_FIELD_WEIGHTS = {
    'discussions.title'        => :A,
    'motion_names'             => :B,
    'discussions.description'  => :C,
    'motion_descriptions'      => :C,
    'comment_bodies'           => :D
  }.freeze

  belongs_to :discussion, dependent: :destroy
  self.table_name = 'discussion_search_vectors'

  validates :discussion, presence: true
  validates :search_vector, presence: true

  scope :search_for, ->(query, user, opts = {}) do
    Queries::VisibleDiscussions.apply_privacy_sql(
      user: user,
      group_ids: user.group_ids,
      relation: search_without_privacy!(query)
    ).offset(opts.fetch(:from, 0)).limit(opts.fetch(:per, 10))
  end

  scope :search_without_privacy!, ->(query) do
    query = sanitize(query)

    joins(discussion: :group)
   .select(:discussion_id, :search_vector, 'groups.full_name as result_group_name')
   .select("ts_rank_cd('{#{WEIGHT_VALUES.join(',')}}', search_vector, plainto_tsquery(#{query})) * #{recency_multiplier} as rank")
   .where("search_vector @@ plainto_tsquery(#{query})")
   .order('rank DESC')
  end

  # NB: I am a convenience method which should be removed soon after we think this thing actually works
  scope :relevence_table, ->(query) do
    search_without_privacy!(query)
      .select("date_part('day', current_date - last_activity_at) as days_old")
      .select("ts_rank_cd('{#{WEIGHT_VALUES.join(',')}}', search_vector, plainto_tsquery(#{sanitize(query)})) as orig_rank")
      .select("#{recency_multiplier} as mult")
      .limit(25).map { |r| puts "|#{r.days_old} | #{r.mult} | #{'%.2f' % r.orig_rank} | #{'%.2f' % r.rank} |" }.compact
  end

  def self.recency_multiplier
    "CASE WHEN date_part('day', current_date - last_activity_at) BETWEEN 0 AND 7   THEN 1.0
          WHEN date_part('day', current_date - last_activity_at) BETWEEN 7 AND 21  THEN 0.8
          WHEN date_part('day', current_date - last_activity_at) BETWEEN 21 AND 42 THEN 0.5
          ELSE                                                                          0.1
     END"
  end

  class << self
    def index!(discussion_ids)
      Array(discussion_ids).map(&:to_i).uniq.tap do |ids|
        existing = where(discussion_id: ids)
        existing.map(&:update_search_vector)
        (ids - existing.map(&:discussion_id)).each { |discussion_id| new(discussion_id: discussion_id).update_search_vector }
      end
    end
    handle_asynchronously :index!
  end

  def self.index_everything!
    index_without_delay! Discussion.pluck(:id)
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
              .joins("LEFT JOIN (#{vector_for_motions.to_sql})  motions ON TRUE")
              .joins("LEFT JOIN (#{vector_for_comments.to_sql}) comments ON TRUE")
              .where(id: self.discussion_id)
  end

  def vector_for_motions
    Motion.select("string_agg(name, ',')                     AS motion_names")
          .select("LEFT(string_agg(description, ','), 10000) AS motion_descriptions")
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
