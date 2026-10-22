class Api::B3::GroupsController < Api::B3::BaseController
  def index
    groups = Group.kept.order(:id)
    render json: {
      groups: page_collection_bounded(groups).map { |group|
        group.attributes.slice('id', 'key', 'name', 'handle', 'parent_id').merge(group_privacy: group.group_privacy)
      },
      meta: { total: groups.count }
    }
  end
end
