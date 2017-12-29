Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'groupTheme', ['$rootScope', ($rootScope) ->
  scope: {group: '=', homePage: '=', compact: '=', discussion: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_theme/group_theme.html'
  replace: true
  controller: ['$scope', ($scope) ->

    $rootScope.$broadcast('setBackgroundImageUrl', $scope.group)

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
