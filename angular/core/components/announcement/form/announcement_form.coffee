angular.module('loomioApp').directive 'announcementForm', (Records) ->
  scope: {announcement: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/form/announcement_form.html'
  controller: ($scope) ->
    $scope.search = (query) ->
      Records.announcements.fetchNotified(query)

    $scope.totalNotified = ->
      _.sum $scope.announcement.notified, (notified) ->
        switch notified.type
          when 'FormalGroup' then notified.notified_ids.length
          when 'User'        then 1
          when 'Invitation'  then 1
