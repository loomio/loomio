Session       = require 'shared/services/session.coffee'
Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ submitForm }    = require 'angular/helpers/form.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'installSlackInstallForm', ->
  templateUrl: 'generated/components/install_slack/install_form/install_slack_install_form.html'
  controller: ($scope) ->
    $scope.groups = ->
      _.filter _.sortBy(Session.user().adminGroups(), 'fullName')

    newGroup = Records.groups.build(name: Session.user().identityFor('slack').customFields.slack_team_name)

    $scope.toggleExistingGroup = ->
      $scope.setSubmit(if $scope.group.id then newGroup else _.first($scope.groups()))

    $scope.setSubmit = (group) ->
      $scope.group = group
      $scope.submit = submitForm $scope, $scope.group,
        prepareFn: ->
          $scope.$emit 'processing'
          $scope.group.identityId = Session.user().identityFor('slack').id
        flashSuccess: 'install_slack.install.slack_installed'
        skipClose: true
        successCallback: (response) ->
          g = Records.groups.find(response.groups[0].key)
          LmoUrlService.goTo LmoUrlService.group(g)
          $scope.$emit 'nextStep', g
    $scope.setSubmit(_.first($scope.groups()) or newGroup)

    submitOnEnter $scope, anyEnter: true
    $scope.$on 'focus',  $scope.focus

    return
