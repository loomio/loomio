AppConfig     = require 'shared/services/app_config.coffee'
Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ applySequence } = require 'angular/helpers/apply.coffee'

# A series of helpers for interacting with polls, such as template values for a
# particular poll or getting the last stance from a given user
module.exports =
  fieldFromTemplate: (pollType, field) ->
    fieldFromTemplate(pollType, field)

  iconFor: (poll) ->
    fieldFromTemplate(poll.pollType, 'material_icon')

  myLastStanceFor: (poll) ->
    _.first _.sortBy(Records.stances.find(
      latest: true
      pollId: poll.id
      participantId: AppConfig.currentUserId
    ), 'createdAt')

  applyPollStartSequence: ($scope, options = {}) ->
    applySequence $scope,
    steps: ->
      if $scope.poll.group()
        ['choose', 'save']
      else
        ['choose', 'save', 'share']
        initialStep: if $scope.poll.pollType then 'save' else 'choose'
        emitter: options.emitter or $scope
        chooseComplete: (_, pollType) ->
          $scope.poll.pollType = pollType
          saveComplete: (_, poll) ->
            $scope.poll = poll
            LmoUrlService.goTo LmoUrlService.poll(poll)
            options.afterSaveComplete(poll) if typeof options.afterSaveComplete is 'function'

fieldFromTemplate = (pollType, field) ->
  (AppConfig.pollTemplates[pollType] or {})[field]
