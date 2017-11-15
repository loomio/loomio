angular.module('loomioApp').directive 'announcementFormActions', ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/announcement/form_actions/announcement_form_actions.html'
  controller: ($scope, KeyEventService) ->
    KeyEventService.submitOnEnter $scope
