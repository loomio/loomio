angular.module('loomioApp').factory 'MembershipRequestForm', ->
  templateUrl: 'generated/components/group_page/membership_request_form/membership_request_form.html'
<<<<<<< HEAD
  controller: ($scope, FormService, Records, group, AbilityService, User) ->
    $scope.membershipRequest = Records.membershipRequests.build
      groupId: group.id
      name:    User.current().name
      email:   User.current().email
=======
  controller: ($scope, FormService, Records, group, AbilityService, Session) ->
    $scope.membershipRequest = Records.membershipRequests.build
      groupId: group.id
      name:    Session.user().name
      email:   Session.user().email
>>>>>>> master

    $scope.submit = FormService.submit $scope, $scope.membershipRequest,
      flashSuccess: 'membership_request_form.messages.membership_requested'
      flashOptions:
        group: group.fullName

    $scope.isLoggedIn = AbilityService.isLoggedIn

    return
