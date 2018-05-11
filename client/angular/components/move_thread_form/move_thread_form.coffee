Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
I18n           = require 'shared/services/i18n'

{ submitForm } = require 'shared/helpers/form'

angular.module('loomioApp').factory 'MoveThreadForm', ->
  templateUrl: 'generated/components/move_thread_form/move_thread_form.html'
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (group) ->
        group.id != discussion.groupId

    $scope.submit = submitForm $scope, $scope.discussion,
      submitFn: $scope.discussion.move
      flashSuccess: 'move_thread_form.messages.success'
      flashOptions:
        name: -> $scope.discussion.group().name

    $scope.updateTarget = ->
      $scope.targetGroup = Records.groups.find($scope.discussion.groupId)
    $scope.updateTarget()

    $scope.moveThread = ->
      if $scope.discussion.private and $scope.targetGroup.privacyIsOpen()
        $scope.submit() if confirm(I18n.t('move_thread_form.confirm_change_to_private_thread', groupName: $scope.targetGroup.name))
      else
        $scope.submit()
  ]
