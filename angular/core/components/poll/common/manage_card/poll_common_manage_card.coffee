angular.module('loomioApp').directive 'pollCommonManageCard', ($translate, FormService, Records, Session, FlashService, AbilityService, LmoUrlService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/manage_card/poll_common_manage_card.html'
  controller: ($scope) ->
    clone = $scope.poll.clone()
    $scope.newEmails = []
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)
    $scope.visitorEmails = Records.visitors.find(pollId: $scope.poll.id)

    noGroupOption = Records.groups.build(id: null, fullName: $translate.instant("poll_common_manage_card.no_group_selected"))
    availableGroups = _.filter Session.user().groups(), (group) ->
      AbilityService.canStartPoll(group)

    $scope.setGroup = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_common_manage_card.set_group"

    $scope.setAnyoneCanParticipate = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_common_manage_card.anyone_can_participate_success"

    $scope.addEmail = ->
      $scope.newEmails.push $scope.newEmail
      $scope.newEmail = ''

    $scope.groupOptions = ->
      [noGroupOption].concat(availableGroups)

    $scope.hasAvailableGroups = ->
      _.any availableGroups

    $scope.copied = ->
      FlashService.success('common.copied')
