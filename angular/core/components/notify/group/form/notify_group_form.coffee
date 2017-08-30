angular.module('loomioApp').directive 'notifyGroupForm', ($translate, Records, LoadingService) ->
  scope: {notified: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/group/form/notify_group_form.html'
  controller: ($scope) ->

    $scope.init = ->
      Records.memberships.fetchByGroup($scope.notified.id, per: 1000).then ->
        Records.groups.findOrFetchById($scope.notified.id).then (group) ->
          $scope.group = group
          $scope.updateVisible()
    LoadingService.applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.updateVisible = ->
      _.map $scope.group.members(), (user) ->
        user.showInNotifyGroup = _.isEmpty($scope.fragment) or
                                 user.name.match(///#{$scope.fragment}///) or
                                 user.username.match(///#{$scope.fragment}///)

    $scope.userIds = {}
    _.each $scope.notified.notified_ids, (id) -> $scope.userIds[id] = true

    $scope.selectedUserIds = ->
      _.map _.keys(_.pick($scope.userIds, _.identity)), (num) -> Number(num)

    $scope.submit = ->
      $scope.notified.notified_ids = $scope.selectedUserIds()
      $scope.notified.subtitle     = $translate.instant "notify_group.group_subtitle", count: $scope.notified.notified_ids.length
      $scope.notified.editing      = false
