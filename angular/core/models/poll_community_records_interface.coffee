angular.module('loomioApp').factory 'PollCommunityRecordsInterface', (BaseRecordsInterface) ->
  class PollCommunityRecordsInterface extends BaseRecordsInterface
    model: {plural: 'poll_communities'}

    revoke: (poll, community, options = {}) ->
      options['poll_id'] = poll.id
      options['community_id'] = community.id
      @remote.delete('', params: options).then -> community.remove()
