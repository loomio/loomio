Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'membersCard', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/members_card/members_card.html'
  controller: ['$scope', ($scope) ->
    $scope.canViewMemberships = ->
      AbilityService.canViewMemberships($scope.model)

    $scope.canAddMembers = ->
      AbilityService.canAdminister($scope.model)

    $scope.showMembersPlaceholder = ->
      $scope.canAddMembers() and $scope.model.memberships().length <= 1

    $scope.invitePeople = ->
      ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel($scope.model)

    if $scope.canViewMemberships() and $scope.model.constructor.singular == 'group'
      Records.memberships.fetchByGroup $scope.model.key, per: 10
  ]
