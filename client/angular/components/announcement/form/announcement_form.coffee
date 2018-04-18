Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'
I18n         = require 'shared/services/i18n.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
utils        = require 'shared/record_store/utils.coffee'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->

    $scope.announcement.recipients = []

    $scope.search = (query) ->
      Records.announcements.search(query, $scope.announcement.model).then (users) ->
        utils.parseJSONList(users)

    $scope.addRecipient = (recipient) ->
      return if !recipient || !recipient.emailHash || _.contains(_.pluck($scope.announcement.recipients, "emailHash"), recipient.emailHash)
      $scope.announcement.recipients.push recipient
      $scope.selected = undefined
      $scope.query = ''

    EventBus.listen $scope, 'removeRecipient', (_event, recipient) ->
      _.pull $scope.announcement.recipients, recipient

    $scope.loadAudience = (kind) ->
      Records.announcements.fetchAudience($scope.announcement.model, kind).then (data) ->
        _.each utils.parseJSONList(data), $scope.addRecipient
  ]
