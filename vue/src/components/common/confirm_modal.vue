<script lang="coffee">
import Flash  from '@/shared/services/flash'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default
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
        @$router.push "#{@confirm.redirect}"     if @confirm.redirect?
        @confirm.successCallback(args...)        if typeof @confirm.successCallback is 'function'
        Flash.success @confirm.text.flash if @confirm.text.flash
      .finally =>
        @isDisabled = false

      _.merge @, confirm.scope # not sure why this is necessary
</script>

<template lang="pug">
v-card.confirm-modal
  submit-overlay(:value='isDisabled')
  v-card-title
    h1.headline(v-t="confirm.text.title")
    v-spacer
    dismiss-modal-button(v-if="!confirm.forceSubmit", :close="close")
  v-card-text
    p(v-html="confirm.text.raw_helptext || $t(confirm.text.helptext)", v-if="confirm.text.raw_helptext || confirm.text.helptext")
  v-card-actions
    v-btn(text v-if="!confirm.forceSubmit" @click="close()" v-t="'common.action.cancel'")
    v-spacer
    v-btn.confirm-modal__submit(color="primary" @click="submit() || close()" v-t="confirm.text.submit || 'common.action.ok'")
</template>
