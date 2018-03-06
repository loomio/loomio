angular.module('loomioApp').directive 'announcementMemberList', ->
  scope: {model: '=', members: '='}
  replace: true
  templateUrl: 'generated/components/announcement/member_list/announcement_member_list.html'
  controller: ['$scope', ($scope) ->
    $scope.showLastAnnounced = (user) ->
      lastAnnouncement = user.lastAnnouncement || {}
      lastAnnouncement.announced_at? and
      lastAnnouncement.announceable_id   == model.id and
      lastAnnouncement.announceable_type == _.capitalize(model.constructor.singular)
  ]
