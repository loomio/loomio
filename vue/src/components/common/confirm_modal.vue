<script lang="coffee">
import Flash  from '@/shared/services/flash'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default
  props:
    close: Function
    confirm: Object

  data: ->
    isDisabled: false
    confirmText: ''

  methods:
    submit: ->
      @isDisabled = true
      @confirm.submit().then =>
        @close()
        @$router.push "#{@confirm.redirect}"     if @confirm.redirect?
        @confirm.successCallback()        if typeof @confirm.successCallback is 'function'
        Flash.success @confirm.text.flash if @confirm.text.flash
      .finally =>
        @isDisabled = false

  computed:
    canProceed: ->
      if @confirm.text.confirm_text
        @confirmText.trim()  == @confirm.text.confirm_text.trim()
      else
        true

</script>

<template lang="pug">
v-card.confirm-modal
  submit-overlay(:value='isDisabled')
  v-card-title
    h1.headline(tabindex="-1" v-html="confirm.text.raw_title || $t(confirm.text.title)", v-if="confirm.text.raw_title || confirm.text.title")
    v-spacer
    dismiss-modal-button(v-if="!confirm.forceSubmit")
  v-card-text
    p(v-html="confirm.text.raw_helptext || $t(confirm.text.helptext)", v-if="confirm.text.raw_helptext || confirm.text.helptext")
    div(v-if="confirm.text.confirm_text")
      p.font-weight-bold {{confirm.text.raw_confirm_text_placeholder}}
      v-text-field.confirm-text-field( v-model="confirmText" v-on:keyup.enter="canProceed && submit()")
  v-card-actions
    v-btn(text v-if="!confirm.forceSubmit" @click="close()" v-t="'common.action.cancel'")
    v-spacer
    v-btn.confirm-modal__submit(:disabled="!canProceed" color="primary" @click="(confirm.submit && submit()) || close()" v-t="confirm.text.submit || 'common.action.ok'")
</template>
