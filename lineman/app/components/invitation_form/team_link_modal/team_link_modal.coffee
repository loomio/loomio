angular.module('loomioApp').factory 'TeamLinkModal', ->
  templateUrl: 'generated/components/invitation_form/team_link_modal/team_link_modal.html'
  controller: ($scope, Records, LoadingService, group, AppConfig, FlashService) ->
    $scope.group = group
    $scope.loading = true

    $scope.load = ->
      Records.invitations.fetchShareableInvitationByGroupId(group.id)

    LoadingService.applyLoadingFunction($scope, 'load')
    $scope.load()

    $scope.invitation = ->
      $scope.group.shareableInvitation()

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      [AppConfig.baseUrl, 'invitations/', $scope.group.shareableInvitation().token].join('')
