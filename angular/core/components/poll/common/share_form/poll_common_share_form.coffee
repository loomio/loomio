angular.module('loomioApp').directive 'pollCommonShareForm', ($translate, FormService, Records, Session, FlashService, AbilityService, KeyEventService, LmoUrlService) ->
  scope: {poll: '=', back: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share_form/poll_common_share_form.html'
  controller: ($scope) ->
    $scope.fetchVisitors = ->
      Records.visitors.fetchByPoll($scope.poll.key).then (response) ->
        $scope.allVisitors = Records.visitors.find(_.pluck(response.visitors, 'id'))
    $scope.fetchVisitors()

    $scope.allVisitors = []
    $scope.newEmails = []
    $scope.newEmail  = ''
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)

    noGroupOption = Records.groups.build(id: null, fullName: $translate.instant("poll_common_share_form.no_group_selected"))
    availableGroups = _.filter Session.user().groups(), (group) ->
      AbilityService.canStartPoll(group)

    $scope.visitors = ->
      _.filter $scope.allVisitors, (visitor) -> !visitor.revoked

    $scope.setGroup = ->
      $scope.settingGroup = true
      $scope.poll.save()
                 .then -> FlashService.success "poll_common_share_form.set_group"
                 .finally -> $scope.settingGroup = false


    $scope.setAnyoneCanParticipate = ->
      $scope.settingAnyoneCanParticipate = true
      $scope.poll.save()
            .then -> FlashService.success "poll_common_share_form.anyone_can_participate_#{$scope.poll.anyoneCanParticipate}"
            .finally -> $scope.settingAnyoneCanParticipate = false

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
               visitor.revoked = true
               FlashService.success "poll_common_share_form.guest_revoked", email: visitor.email

    $scope.remind = (visitor) ->
      visitor.reminding = true
      visitor.remind($scope.poll)
             .then ->    visitor.reminded = true
             .finally -> visitor.reminding = false

    $scope.invite = ->
      $scope.addEmail() if $scope.newEmail.length > 0
      $scope.poll.inviting = true
      $scope.poll.participantEmails = $scope.newEmails
      $scope.poll.save()
                 .then ->
                    $scope.fetchVisitors()
                    FlashService.success "poll_common_share_form.guests_invited", count: $scope.newEmails.length
                    $scope.newEmails = []
                 .finally ->
                   $scope.poll.inviting = false

    $scope.groupOptions = ->
      [noGroupOption].concat(availableGroups)

    $scope.hasAvailableGroups = ->
      # _.any availableGroups
      false # we're not doing groups for this iteration

    $scope.copied = ->
      FlashService.success('common.copied')

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addEmail, (active) ->
      active.classList.contains('poll-common-manage-card__add-option-input')
