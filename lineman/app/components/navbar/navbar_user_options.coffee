angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, DiscussionFormService) ->
    $scope.openDiscussionForm = ->
      DiscussionFormService.openNewDiscussionModal()
  link: (scope, element, attrs) ->
