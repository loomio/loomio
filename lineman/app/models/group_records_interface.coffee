angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup) ->
      @fetch
        path: "#{parentGroup.id}/subgroups"
        cacheKey: "subgroupsFor#{parentGroup.key}"

    archive: (group) =>
      @restfulClient.patchMember(group.id, "archive").then =>
        _.each group.memberships(), (membership) =>
          @recordStore.memberships.remove(membership)
        @recordStore.groups.remove(group)
