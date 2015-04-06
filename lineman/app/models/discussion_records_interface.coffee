angular.module('loomioApp').factory 'DiscussionRecordsInterface', (BaseRecordsInterface, DiscussionModel) ->
  class DiscussionRecordsInterface extends BaseRecordsInterface
    model: DiscussionModel

    fetchByGroup: (options = {}) ->
      @restfulClient.getCollection
        group_id: options['group_id']
        from:     options['from']
        per:      options['per']

    fetchInboxByDate: (options = {}) ->
      @restfulClient.get 'inbox_by_date', options

    fetchInboxByOrganization: (options = {}) ->
      @restfulClient.get 'inbox_by_organization', options

    fetchInboxByGroup: (options = {}) ->
      @restfulClient.get 'inbox_by_group', options

    findByDiscussionIds: (ids) ->
      @collection.chain().find({id: { $in: ids} })
