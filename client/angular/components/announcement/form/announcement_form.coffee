Records        = require 'shared/services/records'
ModalService   = require 'shared/services/modal_service'
I18n           = require 'shared/services/i18n'
EventBus       = require 'shared/services/event_bus'
utils          = require 'shared/record_store/utils'
LmoUrlService  = require 'shared/services/lmo_url_service'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'
{ audiencesFor, audienceValuesFor } = require 'shared/helpers/announcement'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->
    $scope.announcement.model.fetchToken() if $scope.announcement.model.isA('group')

    $scope.canUpdateAnyoneCanParticipate = ->
      $scope.announcement.model.isA('poll') &&
      AbilityService.canAdminister($scope.announcement.model)

    $scope.shareableLink = -> LmoUrlService.shareableLink($scope.announcement.model)

    $scope.announcement.recipients = []

    $scope.audiences      = -> audiencesFor($scope.announcement.model)
    $scope.audienceValues = -> audienceValuesFor($scope.announcement.model)

    $scope.search = (query) ->
      Records.announcements.search(query, $scope.announcement.model).then (users) ->
        utils.parseJSONList(users)

    buildRecipientFromEmail = (email) ->
      email: email
      emailHash: email
      avatarKind: 'mdi-email-outline'

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.addRecipient = (recipient) ->
      return unless recipient
      _.each recipient.emails, (email) -> $scope.addRecipient buildRecipientFromEmail(email)
      if !recipient.emails && !_.includes(_.map($scope.announcement.recipients, "emailHash"), recipient.emailHash)
        $scope.announcement.recipients.unshift recipient
      $scope.selected = undefined
      $scope.query = ''

    EventBus.listen $scope, 'removeRecipient', (_event, recipient) ->
      _.pull $scope.announcement.recipients, recipient

    $scope.loadAudience = (kind) ->
      Records.announcements.fetchAudience($scope.announcement.model, kind).then (data) ->
        _.each _.sortBy(utils.parseJSONList(data), (e) -> e.name || e.email ), $scope.addRecipient
  ]
