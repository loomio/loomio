angular.module('loomioApp').directive 'announcementInput', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/input/announcement_input.html'
  controller: ($scope) ->
    $scope.announcement = Records.announcements.build
      announceableId:   $scope.model.id
      announcebaleType: _.capitalize($scope.model.constructor.singular)

    $scope.search = (query) ->
      Records.notified.fetchByFragment(query)

    $scope.totalNotified = ->
      _.sum $scope.model.notified, (notified) ->
        switch notified.type
          when 'FormalGroup' then notified.notified_ids.length
          when 'User'        then 1
          when 'Invitation'  then 1
