angular.module('loomioApp').directive 'groupPrivacyDropdown', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_privacy_dropdown/group_privacy_dropdown.html'
  replace: true
  controller: 'GroupPrivacyDropdownController'
  link: (scope, element, attrs) ->
