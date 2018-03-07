Records = require 'shared/services/records.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').directive 'announcementMemberList', ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/announcement/member_list/announcement_member_list.html'
  controller: ['$scope', ($scope) ->    
    $scope.init = ->
      Records.announcements.fetchMembersFor($scope.model).then (data) ->
        $scope.members = Records.members.find(_.pluck(data.members, 'key'))
    applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.toggle = (member) ->
      if member.expanded
        member.expanded = false
      else
        member.loading = true
        Records.announcements.fetchMembersFor($scope.model, expand_group: true).then (data) ->
          member.expanded = true
          member.submembers = Records.members.find(_.pluck(data.members, 'key'))
        .finally -> member.loading = false
  ]
