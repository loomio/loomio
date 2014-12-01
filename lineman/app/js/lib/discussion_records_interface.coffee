angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroupKeyAndPage: (groupKey, page, success, failure) ->
      @restfulClient.getCollection({group_key: groupKey, page: page}, @importAndInvoke(success), failure)
