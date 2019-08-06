<script lang="coffee">
import LmoUrlService from '@/shared/services/lmo_url_service'

import { listenForLoading } from '@/shared/helpers/listen'
import { applySequence }    from '@/shared/helpers/apply'

export default
  props:
    group: Object
</script>
<template lang="pug">
v-card.install-slack-form
  .lmo-disabled-form(v-show='isDisabled')
  install-slack-progress(:slack-progress='progress()')
  .install-slack-form__form(ng-switch='currentStep')
    install-slack-install-form(:group='group', ng-switch-when='install')
    install-slack-invite-form(:group='group', ng-switch-when='invite')
    install-slack-decide-form(:group='group', ng-switch-when='decide')
</template>


<!--
angular.module('loomioApp').directive 'installSlackForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ['$scope', ($scope) ->

    applySequence $scope,
      steps:           ['install', 'invite', 'decide']
      initialStep:     if $scope.group then 'invite' else 'install'
      installComplete: (_, group) -> $scope.group = group

    listenForLoading $scope
  ] -->
