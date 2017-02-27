angular.module('loomioApp').directive 'pollCommonManageCard', ($translate, FormService, Records, Session, FlashService, AbilityService, KeyEventService, LmoUrlService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/manage_card/poll_common_manage_card.html'
  controller: ($scope) ->
    Records.visitors.fetchByPoll($scope.poll.key)

    $scope.newEmails = []
    $scope.newEmail  = ''
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)

    noGroupOption = Records.groups.build(id: null, fullName: $translate.instant("poll_common_manage_card.no_group_selected"))
    availableGroups = _.filter Session.user().groups(), (group) ->
      AbilityService.canStartPoll(group)

    $scope.setGroup = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_common_manage_card.set_group"

    $scope.setAnyoneCanParticipate = FormService.submit $scope, $scope.poll,
      flashSuccess: "poll_common_manage_card.anyone_can_participate_success"

    $scope.hasNewEmails = ->
      $scope.newEmails.length > 0

    $scope.addEmail = ->
      if $scope.newEmail.length <= 0
        console.log 'Please enter an email'
      else if _.contains $scope.newEmails, $scope.newEmail
        console.log 'Email already in list'
      else
        $scope.newEmails.push $scope.newEmail
        $scope.newEmail = ''

    $scope.remove = (email) ->
      _.pull $scope.newEmails, email

    $scope.revoke = (visitor) ->
      visitor.destroy()
             .then ->
               visitor.revoking = true
               FlashService.success "poll_common_manage_card.visitor_revoked"

    $scope.remind = (visitor) ->
      visitor.reminding = true
      visitor.remind()
             .then ->    visitor.reminded = true
             .finally -> visitor.reminding = false

    $scope.invite = ->
      $scope.addEmail() if $scope.newEmail.length > 0
      $scope.poll.inviting = true
      $scope.poll.participantEmails = $scope.newEmails
      $scope.poll.save()
                 .then ->
                    Records.visitors.fetchByPoll($scope.poll.key)
                    FlashService.success "poll_common_manage_card.users_invited"
                    $scope.newEmails = []
                 .finally ->
                   $scope.poll.inviting = false

    $scope.groupOptions = ->
      [noGroupOption].concat(availableGroups)

    $scope.hasAvailableGroups = ->
      _.any availableGroups

    $scope.copied = ->
      FlashService.success('common.copied')

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addEmail, (active) ->
      active.classList.contains('poll-common-manage-card__add-option-input')
