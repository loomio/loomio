Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').factory 'MembershipRequestForm', ->
  templateUrl: 'generated/components/group_page/membership_request_form/membership_request_form.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.membershipRequest = Records.membershipRequests.build
      groupId: group.id
      name:    Session.user().name
      email:   Session.user().email

    $scope.submit = submitForm $scope, $scope.membershipRequest,
      flashSuccess: 'membership_request_form.messages.membership_requested'
      flashOptions:
        group: group.fullName

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    return
  ]
