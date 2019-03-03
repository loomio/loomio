Records        = require 'shared/services/records'
AppConfig      = require 'shared/services/app_config'
ModalService   = require 'shared/services/modal_service'
I18n           = require 'shared/services/i18n'
EventBus       = require 'shared/services/event_bus'
utils          = require 'shared/record_store/utils'
LmoUrlService  = require 'shared/services/lmo_url_service'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'
{ audiencesFor, audienceValuesFor } = require 'shared/helpers/announcement'
{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'


angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  template: require('./announcement_form.haml')
  controller: ['$scope', ($scope) ->

    $scope.upgradeUrl = AppConfig.baseUrl + 'upgrade'

    $scope.invitationsRemaining =
      ($scope.announcement.model.group().parentOrSelf().subscriptionMaxMembers || 0) -
      $scope.announcement.model.group().parentOrSelf().orgMembershipsCount

    $scope.showInvitationsRemaining =
      $scope.announcement.model.isA('group') &&
      $scope.announcement.model.group().parentOrSelf().subscriptionMaxMembers

    $scope.subscriptionActive = $scope.announcement.model.group().parentOrSelf().subscriptionActive

    $scope.canInvite = $scope.subscriptionActive && (!$scope.announcement.model.group().parentOrSelf().subscriptionMaxMembers || $scope.invitationsRemaining > 0)

    $scope.tooManyInvitations = ->
      $scope.showInvitationsRemaining && ($scope.invitationsRemaining < $scope.announcement.recipients.length)

    $scope.shareableLink = LmoUrlService.shareableLink($scope.announcement.model)
    if $scope.announcement.model.isA('group')
      $scope.announcement.model.fetchToken().then ->
        $scope.shareableLink = LmoUrlService.shareableLink($scope.announcement.model)

    $scope.canUpdateAnyoneCanParticipate = ->
      $scope.announcement.model.isA('poll') &&
      AbilityService.canAdminister($scope.announcement.model)

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

    $scope.nuggets = [1,2,3,4].map (index) -> "announcement.form.helptext_#{index}"
    $scope.submit = submitForm $scope, $scope.announcement,
      successCallback: (data) ->
        $scope.announcement.membershipsCount = data.memberships.length
        $scope.$emit '$close'
      flashSuccess: 'announcement.flash.success'
      flashOptions: ->
        count: $scope.announcement.membershipsCount
    submitOnEnter($scope, anyInput: true)

  ]
