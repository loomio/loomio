angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroupAndPage: (group, page) ->
      @restfulClient.getCollection group_id: group.id, page: page

    fetchInboxByDate: (options = {}) ->
      @restfulClient.get 'inbox_by_date', options

    fetchInboxByOrganization: (options = {}) ->
      @restfulClient.get 'inbox_by_organization', options

    fetchInboxByGroup: (options = {}) ->
      @restfulClient.get 'inbox_by_group', options

    findByGroupIds: (ids) ->
      @collection.find(groupId: {'$in': ids})
