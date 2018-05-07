Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'groupTheme', ['$rootScope', ($rootScope) ->
  scope: {group: '=', homePage: '=', compact: '=', discussion: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_theme/group_theme.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.logoStyle = ->
      { 'background-image': "url(#{$scope.group.logoUrl()})" }

    $scope.canPerformActions = ->
      AbilityService.isSiteAdmin() or AbilityService.canLeaveGroup($scope.group)

    $scope.canUploadPhotos = ->
      $scope.homePage and AbilityService.canAdministerGroup($scope.group)

    $scope.openUploadCoverForm = ->
      ModalService.open 'CoverPhotoForm', group: => $scope.group

    $scope.openUploadLogoForm = ->
      ModalService.open 'LogoPhotoForm', group: => $scope.group
  ]
]
