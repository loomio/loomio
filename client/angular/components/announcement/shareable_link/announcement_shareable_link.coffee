LmoUrlService = require 'shared/services/lmo_url_service.coffee'
FlashService  = require 'shared/services/flash_service.coffee'

angular.module('loomioApp').directive 'announcementShareableLink', ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/shareable_link/announcement_shareable_link.html'
  controller: ['$scope', ($scope) ->

    $scope.getShareableLink = ->
      $scope.model.anyoneCanParticipate = true
      $scope.model.save()

    $scope.removeShareableLink = ->
      $scope.model.anyoneCanParticipate = false
      $scope.model.save()

    $scope.shareableLink = ->
      LmoUrlService[$scope.model.constructor.singular]($scope.model, {}, absolute: true)

    $scope.copied = ->
      FlashService.success('common.copied')
  ]
