angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroupAndPage: (group, page) ->
      @restfulClient.getCollection group_id: group.id, page: page

    fetchDashboardByDate: (options = {}) ->
      @restfulClient.get 'dashboard_by_date', options

    fetchDashboardByGroup: (options = {}) ->
      @restfulClient.get 'dashboard_by_group', options

    findByDiscussionIds: (ids) ->
      @collection.chain().find({id: { $in: ids} })
