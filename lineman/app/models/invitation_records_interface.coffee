angular.module('loomioApp').factory 'InvitationRecordsInterface', (BaseRecordsInterface, InvitationModel) ->
  class InvitationRecordsInterface extends BaseRecordsInterface
    model: InvitationModel

    create: (params) ->
      @remote.create(params)

    fetchPendingByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @remote.get('/pending', options)
