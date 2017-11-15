angular.module('loomioApp').directive 'announcementForm', (Records) ->
  scope: {model: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ($scope) ->
    $scope.announcement = Records.announcements.build
      announceableId:   $scope.model.id
      announcebaleType: _.capitalize($scope.model.constructor.singular)

    $scope.search = (query) ->
      Records.announcements.fetchNotified(query)

    $scope.totalNotified = ->
      _.sum $scope.model.notified, (notified) ->
        switch notified.type
          when 'FormalGroup' then notified.notified_ids.length
          when 'User'        then 1
          when 'Invitation'  then 1
