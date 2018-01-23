Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
RecordLoader   = require 'shared/services/record_loader.coffee'
FlashService   = require 'shared/services/flash_service.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'verifyStancesPage', skipScroll: true }

  $scope.loader = new RecordLoader
    collection: 'stances'
    path:       'unverified'

  $scope.loader.fetchRecords().then (data) =>
    Records.stances.find(_.pluck(data.stances, 'id')).map (stance) ->
      stance.unverified = true

  $scope.stances = -> Records.stances.find(unverified: true)

  $scope.verify = (stance) ->
    stance.verify().then -> FlashService.success('verify_stances.verify_success')

  $scope.remove = (stance) ->
    stance.destroy().then ->
      FlashService.success('verify_stances.remove_success')

  listenForLoading $scope

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'VerifyStancesPageController', $controller
