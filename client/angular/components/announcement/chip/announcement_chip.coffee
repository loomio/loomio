Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {user: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
