Records = require 'shared/services/records.coffee'

{ applyLoadingFunction } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').factory 'RevisionHistoryModal', ->
  templateUrl: 'generated/components/thread_page/revision_history_modal/revision_history_modal.html'
  controller: ['$scope', 'model', ($scope, model) ->
    $scope.model = model
    $scope.loading = true

    $scope.load = ->
      switch $scope.model.constructor.singular
        when 'discussion' then Records.versions.fetchByDiscussion($scope.model.key)
        when 'comment'    then Records.versions.fetchByComment($scope.model.id)

    $scope.header =
      switch $scope.model.constructor.singular
        when 'discussion' then 'revision_history_modal.thread_header'
        when 'comment'    then 'revision_history_modal.comment_header'

    $scope.discussionRevision = ->
      $scope.model.constructor.singular == 'discussion'

    $scope.commentRevision = ->
      $scope.model.constructor.singular == 'comment'

    $scope.threadTitle = (version) ->
      $scope.model.attributeForVersion('title', version)

    $scope.revisionBody = (version) ->
      switch $scope.model.constructor.singular
        when 'discussion' then $scope.model.attributeForVersion('description', version)
        when 'comment'    then $scope.model.attributeForVersion('body', version)

    $scope.threadDetails = (version) ->
      if version.isOriginal()
        'revision_history_modal.started_by'
      else
        'revision_history_modal.edited_by'

    applyLoadingFunction($scope, 'load')
    $scope.load()

    return
  ]
