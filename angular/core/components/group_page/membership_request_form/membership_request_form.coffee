angular.module('loomioApp').factory 'MembershipRequestForm', ->
  templateUrl: 'generated/components/group_page/membership_request_form/membership_request_form.html'
  controller: ($scope, FormService, Records, group, CurrentUser) ->
    $scope.membershipRequest = Records.membershipRequests.build(groupId: group.id, requestorId: CurrentUser.id)

    $scope.submit = FormService.submit $scope, $scope.membershipRequest,
      flashSuccess: 'membership_request_form.messages.membership_requested'
      flashOptions:
        group: group.fullName
