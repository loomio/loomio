class GroupExporter
  attr_accessor :group

  EXPORT_MODELS = {
    groups:        %w[id key name description created_at],
    memberships:   %w[group_id user_id user_name user_email admin created_at accepted_at],
    discussions:   %w[id topic_id author_id author_name title description created_at],
    comments:      %w[id group_id topic_id author_id author_name title author_name body created_at],
    polls:         %w[id key topic_id author_id author_name title details closing_at closed_at created_at poll_type custom_fields],
    stances:       %w[id poll_id participant_id author_name reason latest created_at updated_at],
    outcomes:      %w[id poll_id author_id statement created_at updated_at]
  }.freeze

  EXPORT_MODELS.keys.each do |model|
    define_method model, -> {
      instance_variable_get(:"@#{model}") ||
      instance_variable_set(:"@#{model}", models_for(model))
    }

    define_method :"#{model.to_s.singularize}_fields", -> { EXPORT_MODELS[model] }
  end
  attr_reader :field_names

  def initialize(group)
    @group = group
    @field_names = {}
  end

  def value_for(model, field)
    model.send(field)
  end

  def to_csv(opts = {})
    CSV.generate(**opts) do |csv|
      csv << ["Export for #{@group.full_name}"]
      csv << []

      EXPORT_MODELS.keys.each do |model|
        csv_append(
          csv:    csv,
          fields: send(:"#{model.to_s.singularize}_fields"),
          models: send(:"#{model}"),
          title:  model.to_s.humanize
        )
      end
    end
  end

  private

  def models_for(model)
    group_ids = @group.id_and_subgroup_ids
    relation = case model
               when :groups
                 Group.where(id: group_ids)
               when :memberships
                 Membership.includes(:user).active.where(group_id: group_ids)
               when :discussions
                 Discussion.includes(:author).joins(:topic).where(topics: { group_id: group_ids })
               when :comments
                 Comment.includes(:user)
                        .joins("INNER JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id")
                        .joins("INNER JOIN topics ON topics.id = topic_items.topic_id")
                        .where(topics: { group_id: group_ids })
               when :polls
                 Poll.kept.joins(:topic).where(topics: { group_id: group_ids })
               when :stances
                 Stance.joins(:poll)
                       .joins("LEFT JOIN topics ON topics.id = polls.topic_id")
                       .where(topics: { group_id: group_ids })
               when :outcomes
                 Outcome.joins(:poll)
                        .joins("LEFT JOIN topics ON topics.id = polls.topic_id")
                        .where(topics: { group_id: group_ids })
               else
                 raise ArgumentError, "Unsupported export model: #{model}"
               end

    relation.order(relation.klass.arel_table[:created_at].asc)
  end

  def csv_append(csv:, fields:, models:, title:)
    csv << ["#{title} (#{models.length})"]
    csv << fields.map(&:humanize)
    models.each { |model| csv << fields.map { |field| value_for(model, field) } }
    csv << []
  end
end
