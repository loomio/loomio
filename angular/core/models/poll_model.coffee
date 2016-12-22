angular.module('loomioApp').factory 'PollModel', (DraftableModel, AppConfig) ->
  class PollModel extends DraftableModel
    @singular: 'poll'
    @plural: 'polls'
    @indices: ['discussionId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.poll
    @draftParent: 'discussion'

    defaultValues: ->
      discussionId: null
      title: ''
      details: ''
      closingAt: moment().add(3, 'days').startOf('hour')

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'

    group: ->
      @discussion().group()
