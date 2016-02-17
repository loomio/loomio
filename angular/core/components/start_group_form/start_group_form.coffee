angular.module('loomioApp').factory 'StartGroupForm', ->
  templateUrl: 'generated/components/start_group_form/start_group_form.html'
  controller: ($scope, $rootScope, $location, group, Records, FormService, ModalService, GroupWelcomeModal, KeyEventService) ->
    $scope.group = group

    $scope.submit = FormService.submit $scope, $scope.group,
      if $scope.group.isSubgroup()
        allowDrafts: true
        flashSuccess: 'start_group_form.messages.success_when_subgroup'
        successCallback: (response) ->
          $location.path "/g/#{response.groups[0].key}"
      else
        allowDrafts: true
        successCallback: (response) ->
          $location.path "/g/#{response.groups[0].key}"
          ModalService.open GroupWelcomeModal

    KeyEventService.submitOnEnter $scope
