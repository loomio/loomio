angular.module('loomioApp').factory 'GroupRecordsInterface', (BaseRecordsInterface, GroupModel) ->
  class GroupRecordsInterface extends BaseRecordsInterface
    @model: GroupModel

    fetchByParent: (parent, success, failure) ->
      @restfulClient().fetch({parent_id: parent.id}, success, failure, 'subgroups')

    archive: (group, success, failure) =>
      @save(group, success, failure, 'archive')
