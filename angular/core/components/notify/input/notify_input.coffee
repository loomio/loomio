angular.module('loomioApp').directive 'notifyInput', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/input/notify_input.html'
  controller: ($scope) ->
    $scope.search = (query) ->
      Records.notified.fetchByFragment(query)

    $scope.totalNotified = ->
      _.sum $scope.model.notified, (notified) ->
        switch notified.type
          when 'FormalGroup' then notified.notified_ids.length
          when 'User'        then 1
          when 'Invitation'  then 1
