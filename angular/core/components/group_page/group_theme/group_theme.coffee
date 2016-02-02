angular.module('loomioApp').directive 'groupTheme', ->
  scope: {group: '=', homePage: '=', compact: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_theme/group_theme.html'
  replace: true
  controller: ($scope, CurrentUser, AbilityService, ModalService, CoverPhotoForm, LogoPhotoForm) ->

    $scope.logoStyle = ->
      { 'background-image': "url(#{$scope.group.logoUrl()})" }

    $scope.coverStyle = ->
      { 'background-image': "url(#{$scope.group.coverUrl()})", 'z-index': (-1 if $scope.compact) }

    $scope.isMember = ->
      CurrentUser.membershipFor($scope.group)?

    $scope.canUploadPhotos = ->
      $scope.homePage and AbilityService.canAdministerGroup($scope.group)

    $scope.openUploadCoverForm = ->
      ModalService.open CoverPhotoForm, group: => $scope.group

    $scope.openUploadLogoForm = ->
      ModalService.open LogoPhotoForm, group: => $scope.group

    $scope.themeHoverIn = ->
      $scope.themeHover = true

    $scope.themeHoverOut = ->
      $scope.themeHover = false

    $scope.logoHoverIn = ->
      $scope.logoHover = true

    $scope.logoHoverOut = ->
      $scope.logoHover = false
