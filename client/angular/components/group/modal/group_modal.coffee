Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ applySequence } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').factory 'GroupModal', ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    applySequence $scope,
      steps: ->
        if $scope.group.isNew() or $scope.group.parentId
          ['create', 'invite']
        else
          ['create']
      createComplete: (_, g) ->
        $scope.invitationForm = Records.invitationForms.build(groupId: g.id)
        LmoUrlService.goTo LmoUrlService.group(g)
