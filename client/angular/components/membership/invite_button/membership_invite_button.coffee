Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
RecordLoader   = require 'shared/services/record_loader.coffee'
I18n           = require 'shared/services/i18n.coffee'
Records        = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'membershipInviteButton', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/membership/invite_button/membership_invite_button.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.plusUser = Records.users.build(avatarKind: 'mdi-plus')

    $scope.invite = ->
      ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel($scope.group.targetModel())

    $scope.canAddMembers = ->
      AbilityService.canAddMembers($scope.group)
  ]
