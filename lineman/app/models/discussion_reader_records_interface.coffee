angular.module('loomioApp').factory 'DiscussionReaderRecordsInterface', (BaseRecordsInterface, DiscussionReaderModel) ->
  class DiscussionReaderRecordsInterface extends BaseRecordsInterface
    model: DiscussionReaderModel

    initialize: (data = {}) ->
      data.id = data.discussion_id if data.discussion_id?
      @baseInitialize(data)

    forDashboard: (options = {}) -> 
      relation = @collection.chain()
      relation = relation.find({ volume: { $eq: 'mute'} })                           if options['muted']
      relation = relation.find({ volume: { $ne: 'mute'} })                           unless options['muted']
      relation = relation.find({ participating: { $eq: true } })                     if options['participating']
      relation = relation.where((reader) -> reader.discussion().hasActiveProposal()) if options['proposals']
      relation = relation.where((reader) -> reader.discussion().isUnread())          if options['unread']
      relation