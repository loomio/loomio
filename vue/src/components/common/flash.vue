<script lang="coffee">
export default
  props:
  data: ->
    flash: {}
    pendingDismiss: null
  created: ->
    # EventBus.listen @, 'flashMessage', (event, flash) =>
    #   @flash = _.merge flash, { visible: true }
    #   @flash.message = @flash.message or 'common.action.loading' if @loading()
    #   $interval.cancel @pendingDismiss if @pendingDismiss?
    #   @pendingDismiss = $interval(@dismiss, flash.duration, 1)
    #
    # EventBus.listen $scope, 'dismissFlash', @dismiss
  computed:
    loading: -> @flash.level == 'loading'
    display: -> @flash.visible
    dismiss: -> @flash.visible = false
    ariaLive: ->
      if @loading()
        'polite'
      else
        'assertive'
</script>

<template>
  <div :aria-live="ariaLive()" role="alert" class="flash-root">
    <div v-if="display()" ng-animate="'enter'" :class="'flash-root__container animated alert-' + flash.level">
      <div v-if="loading()" class="flash-root__message--loading lmo-flex lmo-flex__center">
        <v-progress-circular size="25" class="md-accent flash-root__loading lmo-margin-right"></v-progress-circular>
        {{ flash.message | translate:flash.options }}
      </div>
      <div v-if="!loading()" class="flash-root__message lmo-flex lmo-flex__center lmo-margin-right">{{ flash.message | translate:flash.options }}</div>
      <div v-if="flash.actionFn" class="flash-root__action">
        <a md-colors="{color: 'accent'}" @click="flash.actionFn()" v-t="flash.action"></a>
      </div>
    </div>
  </div>
</template>
