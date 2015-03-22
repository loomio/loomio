angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroupAndPage: (group, page) ->
      @restfulClient.getCollection group_id: group.id, page: page

    fetchInboxByDate: (options = {}) ->
      @restfulClient.get 'inbox_by_date', options

    fetchInboxByGroup: (options = {}) ->
      @restfulClient.get 'inbox_by_group', options

