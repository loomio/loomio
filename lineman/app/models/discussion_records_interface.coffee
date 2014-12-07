angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroupAndPage: (group, page, success, failure) ->
      @restfulClient.getCollection group_id: group.id, page: page

    fetchInbox: ->
      @restfulClient.get 'inbox'
