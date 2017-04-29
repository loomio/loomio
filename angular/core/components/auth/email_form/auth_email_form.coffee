angular.module('loomioApp').directive 'authEmailForm', (Records) ->
  scope: {user: '=', preventClose: '='}
  templateUrl: 'generated/components/auth/email_form/auth_email_form.html'
  controller: ($scope) ->
    $scope.save = ->
      $scope.$emit 'saveBegin'
      Records.users.emailStatus($scope.email).then (data) ->
        _.merge $scope.user, Records.users.find(data.users[0].id)
      .finally -> $scope.$emit 'saveComplete'
