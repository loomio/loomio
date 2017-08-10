module UsesOrganisationScope
  extend ActiveSupport::Concern

  included do
    scope :in_organisation, -> (group) { where(group_id: group.id_and_subgroup_ids) }
  end
end
