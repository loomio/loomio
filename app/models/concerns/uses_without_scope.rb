module UsesWithoutScope
  extend ActiveSupport::Concern

  included do
    scope :without, -> (models) {
      return all unless models = Array(models).compact.presence
      where("#{table_name}.id NOT IN (?)", models)
    }
  end
end
