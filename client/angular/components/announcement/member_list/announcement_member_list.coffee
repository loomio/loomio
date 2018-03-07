Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementMemberList', ->
  scope: {model: '=', members: '='}
  replace: true
  templateUrl: 'generated/components/announcement/member_list/announcement_member_list.html'
  controller: ['$scope', ($scope) ->
    Records.announcements.fetchMembersFor($scope.model).then (data) ->
      $scope.members = Records.members.find(_.pluck(data.members, 'key'))
  ]
