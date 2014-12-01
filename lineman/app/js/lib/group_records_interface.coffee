angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup, success, failure) ->
      @restfulClient.get "#{parentGroup.id}/subgroups", {}, @importAndInvoke(success), failure

    archive: (group, success, failure) =>
      @restfulClient.post "#{group.key}/archive", {}, @importAndInvoke(success), failure
