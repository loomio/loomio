angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup) ->
      @fetch
        path: "#{parentGroup.id}/subgroups"
        cacheKey: "subgroupsFor#{parentGroup.key}"

    uploadPhoto: (group, file, kind) =>
      @remote.upload "#{group.key}/upload_photo/#{kind}", file
