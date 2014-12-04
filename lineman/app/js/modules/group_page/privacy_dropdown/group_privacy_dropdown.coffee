angular.module('loomioApp').directive 'groupPrivacyDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/group_privacy_dropdown.html'
  replace: true
  controller: 'GroupPrivacyDropdownController'
  link: (scope, element, attrs) ->
