angular.module('loomioApp').controller 'InstallSlackPageController', ($scope, $rootScope, Records, Session, FormService) ->
  $rootScope.$broadcast('currentComponent', { page: 'installSlackPage' })

  $scope.groups = ->
    Session.user().adminGroups()

  newGroup = Records.groups.build(name: Session.user().slackIdentity().customFields.slack_team_name)
  $scope.group = _.first($scope.groups()) or newGroup

  $scope.toggleExistingGroup = ->
    if $scope.group.id
      $scope.group = newGroup
    else
      $scope.group = _.first($scope.groups())
    $scope.setSubmit()

  $scope.setSubmit = ->
    $scope.submit = FormService.submit $scope, $scope.group,
      prepareFn: ->
        $scope.group.slackIdentityId = Session.user().slackIdentity().id
      successCallback: ->
        console.log 'did it!'
  $scope.setSubmit()

  return
