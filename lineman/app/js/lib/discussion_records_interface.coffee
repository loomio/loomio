angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    @model: DiscussionModel

    fetchByKey: (key) ->
      @restfulClient.fetch(key: key)

    fetchByGroup: (group, page, success, failure) ->
      @fetch({group_id: group.id, page: page}, success, failure)
