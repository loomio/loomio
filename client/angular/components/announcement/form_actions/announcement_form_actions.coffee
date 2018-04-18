{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'announcementFormActions', ->
  scope: {announcement: '='}
  replace: true
  templateUrl: 'generated/components/announcement/form_actions/announcement_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.nuggets = [1,2,3,4].map (index) -> "announcement.form.helptext_#{index}"
    $scope.submit = submitForm $scope, $scope.announcement,
      successCallback: (data) ->
        $scope.announcement.membershipsCount = data.memberships.length
        $scope.$emit '$close'
      flashSuccess: 'announcement.flash.success'
      flashOptions:
        count: -> $scope.announcement.membershipsCount
  ]
