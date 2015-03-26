angular.module('loomioApp').factory 'DiscussionReaderRecordsInterface', (BaseRecordsInterface, DiscussionReaderModel) ->
  class DiscussionReaderRecordsInterface extends BaseRecordsInterface
    model: DiscussionReaderModel

    initialize: (data = {}) ->
      data.id = data.discussion_id if data.discussion_id?
      @baseInitialize(data)

    forDashboard: (options = {}) ->
      relation = @collection.chain()
      relation = relation.find({ volume: { $ne: 'mute'} })     if options['unmuted']
      relation = relation.find({ groupId: options['groupId']}) if options['groupId']
      relation = relation.where((reader) -> reader.discussion().isUnread())   if options['unread']
      relation