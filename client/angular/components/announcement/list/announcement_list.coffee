Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementList', ->
  scope: {model: '='}
  replace: true
  templateUrl: 'generated/components/announcement/list/announcement_list.html'
  controller: ['$scope', ($scope) ->
    Records.announcements.fetchByModel($scope.model)
  ]
