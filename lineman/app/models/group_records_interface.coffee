angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    model: GroupModel

    fetchByParent: (parentGroup) ->
      @fetch
        path: "#{parentGroup.id}/subgroups"
        cacheKey: "subgroupsFor#{parentGroup.key}"

    uploadCoverPhoto: (group, file) =>
      @remote.upload "groups/#{group.key}/upload_cover_photo", file

    uploadLogo: (group, file) =>
      @remote.upload "groups/#{group.key}/upload_logo", file
