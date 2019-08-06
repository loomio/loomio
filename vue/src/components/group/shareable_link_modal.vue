<script lang="coffee">
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import Flash   from '@/shared/services/flash'


export default
  props:
    group: Object
  data: ->
    dialog: false

  created: ->
    @group.fetchToken()

  methods:
    copied: (e) ->
      @$copyText(e.text, @$refs.copyContainer.$el)
      Flash.success('common.copied')

    resetShareableLink: ->
      @group.resetToken().then =>
        Flash.success('invitation_form.shareable_link_reset')

  computed:
    shareableLink: ->
      if @group.token
        LmoUrlService.shareableLink(@group)
      else
        @$t('common.action.loading')

</script>

<template lang="pug">
v-dialog(v-model='dialog' max-width="600px")
  template(v-slot:activator="{ on }")
    v-btn(v-on="on" outlined color="accent" v-t="'members_panel.sharable_link'") 
  v-card.shareable-link-modal
    v-card-title
      h1.headline(v-t="'invitation_form.shareable_link'")
      v-spacer
      v-btn.dismiss-modal-button(icon small @click='dialog = false')
        v-icon mdi-window-close
    v-card-text
      p.caption(v-t="'invitation_form.shareable_link_explanation'")
      v-layout(align-center)
        v-text-field.shareable-link-modal__shareable-link(:value='shareableLink' :disabled='true')
        v-btn.shareable-link-modal__copy(ref="copyContainer" text color="accent" v-t="'common.copy'" v-clipboard:copy='shareableLink' v-clipboard:success='copied' v-clipboard:error='"fuck"')
        v-btn.shareable-link-modal__reset(text color="warning" v-t="'common.reset'" @click="resetShareableLink()")
</template>
