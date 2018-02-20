angular.module('loomioApp').directive 'announcementList', ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/announcement/list/announcement_list.html'
