angular.module('loomioApp').directive 'installSlackInstallForm', ($location, FormService, Session, Records, LmoUrlService) ->
  templateUrl: 'generated/components/install_slack/install_form/install_slack_install_form.html'
  controller: ($scope) ->
    $scope.groups = ->
      _.filter Session.user().adminGroups(), (group) -> !group.slackIdentityId

    newGroup = Records.groups.build(name: Session.user().slackIdentity().customFields.slack_team_name)
    $scope.group = _.first($scope.groups()) or newGroup
    $scope.showTooltip = !Session.user().hasExperienced('install_slack')

    $scope.hideTooltip = ->
      $scope.showTooltip = false
      Records.users.saveExperience('install_slack')

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
        flashSuccess: 'install_slack.slack_added_to_group'
        skipClose: true
        prepareFn: -> $scope.$emit 'processing'
        successCallback: (response) ->
          group = Records.groups.find(response.groups[0].key)
          $location.path LmoUrlService.group(group)
          $scope.$emit 'installComplete'
    $scope.setSubmit()

    return
