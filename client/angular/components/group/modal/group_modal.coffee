Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ applySequence } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'GroupModal', ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.group = group.clone()

    applySequence $scope,
      steps: ->
        if $scope.group.isNew() or $scope.group.parentId
          ['create', 'announce']
        else
          ['create']
      createComplete: (_, group) ->
        $scope.announcement = Records.announcements.buildFromModel(group)
        LmoUrlService.goTo LmoUrlService.group(group)
  ]
