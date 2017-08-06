angular.module('loomioApp').controller 'VerifyStancesPageController', ($scope, $rootScope, Session, Records, LoadingService, RecordLoader, FlashService)->
  $rootScope.$broadcast('currentComponent', { page: 'verifyStancesPage', skipScroll: true })

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

  LoadingService.listenForLoading $scope

  return
