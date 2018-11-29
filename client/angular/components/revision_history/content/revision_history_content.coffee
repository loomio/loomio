Records = require 'shared/services/records.coffee'
{ exactDateWithTime } = require 'shared/helpers/filters.coffee'

angular.module('loomioApp').directive 'revisionHistoryContent', ->
  scope:{model:'=', version:'='}
  restrict:'E'
  templateUrl: 'generated/components/revision_history/content/revision_history_content.html'
  controller:['$scope', ($scope) ->

    $scope.diffType = (field_name) ->
      # depending on the model type we will have different kinds
      switch field_name
        when "body", "description", "title", "reason" then (if $scope.version.changes[field_name][0] then "diff" else "original");
        when "group_id", "private" then "notice";

    $scope.noticeValues = (field_name) ->
      switch field_name
        when "group_id" then { name:Records.groups.find($scope.version.changes.group_id[1]).name}
        when "private" then { private: if $scope.version.changes.private[1] then "private" else "public"}
        when "closing_at" then {time: exactDateWithTime($scope.version.changes.closing_at[1])}
  ]
