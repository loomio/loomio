angular.module('loomioApp').directive 'announcementFormActions', (FormService) ->
  scope: {announcement: '='}
  replace: true
  templateUrl: 'generated/components/announcement/form_actions/announcement_form_actions.html'
  controller: ($scope) ->
    $scope.submit = FormService.submit $scope, $scope.announcement,
      successCallback: -> $scope.$emit '$close'
      flashSuccess: 'announcement.flash.success'
