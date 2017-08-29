angular.module('loomioApp').directive 'notifyGroupForm', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/group/form/notify_group_form.html'
  controller: ($scope) ->
