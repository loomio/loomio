angular.module('loomioApp').directive 'pollCommonShareForm', ($translate, FormService, Records, Session, FlashService, AbilityService, KeyEventService, LmoUrlService) ->
  scope: {poll: '=', back: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share_form/poll_common_share_form.html'
  controller: ($scope) ->
    Records.visitors.fetch(params: {community_id: $scope.poll.emailCommunityId})

    $scope.init = ->
      $scope.newVisitor = Records.visitors.build(email: '', communityId: $scope.poll.emailCommunityId)
    $scope.init()

    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)

    # noGroupOption = Records.groups.build(id: null, fullName: $translate.instant("poll_common_share_form.no_group_selected"))
    # availableGroups = _.filter Session.user().groups(), (group) ->
    #   AbilityService.canStartPoll(group)

    $scope.visitors = ->
      Records.visitors.find(communityId: $scope.poll.emailCommunityId)

    # $scope.setGroup = ->
    #   $scope.settingGroup = true
    #   $scope.poll.save()
    #              .then -> FlashService.success "poll_common_share_form.set_group"
    #              .finally -> $scope.settingGroup = false

    $scope.setAnyoneCanParticipate = ->
      $scope.settingAnyoneCanParticipate = true
      $scope.poll.save()
            .then -> FlashService.success "poll_common_share_form.anyone_can_participate_#{$scope.poll.anyoneCanParticipate}"
            .finally -> $scope.settingAnyoneCanParticipate = false

    $scope.invite = ->
      if $scope.newVisitor.email.length <= 0
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_empty')
      else if _.contains(_.pluck($scope.visitors(), 'email'), $scope.newVisitor.email)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_exists', email: $scope.newVisitor.email)
      else if !$scope.newVisitor.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_invalid')
      else
        $scope.emailValidationError = null
        $scope.newVisitor.save().then ->
          FlashService.success 'poll_common_share_form.email_invited', email: $scope.newVisitor.email
          $scope.init()
          document.querySelector('.poll-common-share-form__add-option-input').focus()

    $scope.revoke = (visitor) ->
      visitor.destroy()
             .then ->
               visitor.revoked = true
               FlashService.success "poll_common_share_form.guest_revoked", email: visitor.email

    $scope.remind = (visitor) ->
      visitor.remind($scope.poll).then ->
        visitor.reminded = true
        FlashService.success 'poll_common_share_form.email_invited', email: visitor.email

    # $scope.groupOptions = ->
    #   [noGroupOption].concat(availableGroups)

    $scope.hasAvailableGroups = ->
      # _.any availableGroups
      false # we're not doing groups for this iteration

    $scope.copied = ->
      FlashService.success('common.copied')

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.invite, (active) ->
      active.classList.contains('poll-common-share-form__add-option-input')
