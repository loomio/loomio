Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'
I18n         = require 'shared/services/i18n.coffee'

angular.module('loomioApp').directive 'announcementForm', ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ['$scope', ($scope) ->
    $scope.recipients = []

    $scope.search = (query) ->
      Records.announcements.search(query).then (users) ->
        _.map users, (user) -> Records.users.importJSON(user)

    $scope.addRecipient = (recipient) ->
      return if !recipient || !recipient.name || _.contains($scope.recipients, recipient)
      $scope.recipients.push recipient
  ]
