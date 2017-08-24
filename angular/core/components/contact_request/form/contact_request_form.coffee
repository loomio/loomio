angular.module('loomioApp').directive 'contactRequestForm', (Records, FormService) ->
  scope: {user: '='}
  templateUrl: 'generated/components/contact_request/form/contact_request_form.html'
  controller: ($scope) ->

    $scope.contactRequest = Records.contactRequests.build(user: $scope.user)

    $scope.submit = FormService.submit $scope, $scope.contactRequest,
      flashSuccess: "contact_user_form.email_sent"
