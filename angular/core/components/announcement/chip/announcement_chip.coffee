angular.module('loomioApp').directive 'notifyChip', ->
  scope: {chip: '='}
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
