<style lang="scss">
</style>

<script lang="coffee">
FlashService  = require 'shared/services/flash_service'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports =
  props:
    close: Function
    confirm: Object
  data: ->
    isDisabled: false
  computed:
    fragment: ->
      "generated/components/fragments/#{@confirm.text.fragment}.html" if @confirm.text.fragment
  created: ->
    @submit = (args...) =>
      @isDisabled = true
      @confirm.submit(args...).then =>
        @close()
        @$router.push @confirm.redirect     if @confirm.redirect?
        @confirm.successCallback(args...)        if typeof @confirm.successCallback is 'function'
        # FlashService.success $scope.confirm.text.flash if $scope.confirm.text.flash
      .finally =>
        @isDisabled = false

      # _.merge $scope, confirm.scope # not sure why this is necessary
</script>

<template lang="pug">
v-card.confirm-modal
  //- .lmo-disabled-form(v-show="isDisabled")
  v-card-title
    v-layout(justify-space-between, align-center)
      h1.lmo-h1(v-t="confirm.text.title")
      dismiss-modal-button(v-if="!confirm.forceSubmit", :close="close")
  v-card-text
    p(v-t="confirm.text.helptext", v-if="confirm.text.helptext")
    //- p(ng-include="fragment", ng-if="fragment")
  v-card-actions
    div(v-if="confirm.forceSubmit")
    v-btn(v-if="!confirm.forceSubmit", @click="close()", type="button", v-t="'common.action.cancel'")
    v-btn.confirm-modal__submit(@click="submit() || close()", v-t="confirm.text.submit || 'common.action.ok'", primary, raised)
</template>
