angular.module('loomioApp').directive 'pollCommonShareVisitorForm', (Records, KeyEventService, FlashService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/visitor_form/poll_common_share_visitor_form.html'
  controller: ($scope) ->

    $scope.visitors = ->
      Records.visitors.find(communityId: $scope.poll.emailCommunityId)

    $scope.init = ->
      Records.visitors.fetch(params: {community_id: $scope.poll.emailCommunityId})
      $scope.newVisitor = Records.visitors.build(email: '', communityId: $scope.poll.emailCommunityId)
    $scope.init()

    $scope.invite = ->
      if $scope.newVisitor.email.length <= 0
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_empty')
      else if _.contains(_.pluck($scope.visitors(), 'email'), $scope.newVisitor.email)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_exists', email: $scope.newVisitor.email)
      else if !$scope.newVisitor.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)
        $scope.emailValidationError = $translate.instant('poll_common_share_form.email_invalid')
      else
        $scope.emailValidationError = null
        $scope.newVisitor.invite($scope.poll).then ->
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

    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.invite, (active) ->
      active.classList.contains('poll-common-share-form__add-option-input')
