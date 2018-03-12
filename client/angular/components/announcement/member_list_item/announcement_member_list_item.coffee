Session = require 'shared/services/session.coffee'

angular.module('loomioApp').directive 'announcementMemberListItem', ->
  scope: {member: '=', indented: '=?'}
  replace: true
  templateUrl: 'generated/components/announcement/member_list_item/announcement_member_list_item.html'
  controller: ['$scope', ($scope) ->
    $scope.displayTimestampFor = (member) ->
      !(member.type == 'User' and member.key == "user-#{Session.user().id}") and
      !($scope.indented and member.type == 'Invitation')
  ]
