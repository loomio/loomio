angular.module('loomioApp').factory 'MembershipRequestForm', ->
  templateUrl: 'generated/components/group_page/membership_request_form/membership_request_form.html'
  controller: ($scope, FlashService, Records, group, CurrentUser) ->
    $scope.membershipRequest = Records.membershipRequests.build(groupId: group.id, requestorId: CurrentUser.id)

    $scope.submit = ->
      $scope.membershipRequest.save().then ->
        $scope.$close()
        FlashService.success('membership_request_form.messages.membership_requested', group: group.fullName())
