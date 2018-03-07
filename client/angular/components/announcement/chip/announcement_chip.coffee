AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'
{ parseJSON } = require 'shared/record_store/utils.coffee'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
  controller: ['$scope', ($scope) ->
    $scope.$watch 'chip.logo_url', ->
      $scope.userForAvatar = Records.members.build(parseJSON($scope.chip))
  ]
