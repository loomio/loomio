angular.module('loomioApp').directive 'invitable', ->
  scope: { invitable: '=' }
  restrict: 'E'
  templateUrl: 'generated/components/invitation_form/invitable.html'
  replace: true
  controller: ($scope) ->
    # So that typeahead and our regular ng-repeat can use the same template
    $scope.match =
      label: $scope.invitable

    return
