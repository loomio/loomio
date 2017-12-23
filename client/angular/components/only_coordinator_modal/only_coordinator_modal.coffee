Session       = require 'shared/services/session.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').factory 'OnlyCoordinatorModal', ($location) ->
  templateUrl: 'generated/components/only_coordinator_modal/only_coordinator_modal.html'
  controller: ($scope) ->

    $scope.groups = ->
      _.filter Session.user().groups(), (group) ->
        _.contains(group.adminIds(), Session.user().id) and
        !group.hasMultipleAdmins

    $scope.redirectToGroup = (group) ->
      $location.path LmoUrlService.group(group)
      $scope.$close()
