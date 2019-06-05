<script lang="coffee">
import EventBus from '@/shared/services/event_bus'

import { submitPoll } from '@/shared/helpers/form'

export default
  props:
    poll: Object
  data: ->
    submit: null
  created: ->
    @submit = submitPoll @, @poll,
      submitFn: @poll.addOptions
      prepareFn: =>
        @poll.addOption()
      successCallback: =>
        # EventBus.broadcast $rootScope, 'pollOptionsAdded', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
</script>
<template lang="pug">
.lmo-md-action
  md-button.md-raised.md-primary(ng-click='submit()', translate='poll_common_add_option.form.add_options')
</template>
<style lang="scss">
</style>


EventBus = require 'shared/services/event_bus'

{ submitPoll } = require 'shared/helpers/form'

angular.module('loomioApp').directive 'pollCommonAddOptionFormActions', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/form_actions/poll_common_add_option_form_actions.html'
  replace: true
  controller: ['$scope', '$rootScope', ($scope, $rootScope) ->
    $scope.submit = submitPoll $scope, $scope.poll,
      submitFn: $scope.poll.addOptions
      prepareFn: ->
        $scope.poll.addOption()
        EventBus.emit $scope, 'processing'
      successCallback: ->
        EventBus.broadcast $rootScope, 'pollOptionsAdded', $scope.poll
      flashSuccess: "poll_common_add_option.form.options_added"
  ]
