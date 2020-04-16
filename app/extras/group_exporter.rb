class GroupExporter
  attr_accessor :group

  EXPORT_MODELS = {
    groups: %w[id key name description created_at],
    memberships:   %w[group_id user_id user_name user_email admin created_at accepted_at],
    discussions:   %w[id group_id author_id author_name title description created_at],
    comments:      %w[id group_id discussion_id author_id discussion_title author_name body created_at],
    polls:         %w[id key discussion_id group_id author_id title details closing_at closed_at created_at poll_type multiple_choice custom_fields],
    stances:       %w[id poll_id participant_id reason latest created_at updated_at]
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

  def to_csv(opts = {})
    CSV.generate(opts) do |csv|
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
    model.to_s.classify.constantize.in_organisation(@group).order(created_at: :asc)
  end

  def csv_append(csv:, fields:, models:, title:)
    csv << ["#{title} (#{models.length})"]
    csv << fields.map(&:humanize)
    models.each { |model| csv << fields.map { |field| model.send(field) } }
    csv << []
  end
end
