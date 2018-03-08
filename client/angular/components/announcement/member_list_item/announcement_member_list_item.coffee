angular.module('loomioApp').directive 'announcementMemberListItem', ->
  scope: {member: '=', indented: '=?'}
  replace: true
  templateUrl: 'generated/components/announcement/member_list_item/announcement_member_list_item.html'
