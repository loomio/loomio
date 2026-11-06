# Share hydrated groups between the signed-in directory and an authorized page's
# group response. A public page's group can be outside the viewer's directory.
class GroupDirectory
  def initialize(user:, context_group: nil, exclude_types: ['user'])
    @user = user
    @context_group = context_group
    @exclude_types = exclude_types
  end

  def records
    @records ||= begin
      groups = GroupQuery.visible_to(user: @user).to_a
      groups << @context_group if @context_group && groups.none? { |group| group.id == @context_group.id }
      groups
    end
  end

  def cache
    @cache ||= RecordCache.for_collection(records, @user.id, @exclude_types)
  end

  def scope
    @scope ||= {cache: cache, current_user_id: @user.id, exclude_types: @exclude_types}
  end

  def serialize(groups = records, exclude_types: @exclude_types)
    loaded = cache.scope.fetch(:groups_by_id, {})
    groups = groups.map { |group| loaded.fetch(group.id, group) }
    ActiveModel::ArraySerializer.new(groups, each_serializer: GroupSerializer, root: :groups,
      scope: scope.merge(exclude_types: exclude_types)).as_json
  end

  def payload
    @payload ||= serialize
  end
end
