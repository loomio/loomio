<script lang="coffee">
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'

import Flash   from '@/shared/services/flash'


export default
  props:
    group: Object
  data: ->
    dialog: false

  created: ->
    @group.fetchToken()

  methods:
    error: ->
      Flash.error('invitation_form.error')

    copiedGroupUrl: (e) ->
      @$copyText(e.text, @$refs.groupUrlButton.$el)
      Flash.success('common.copied')

    copiedInvitationUrl: (e) ->
      @$copyText(e.text, @$refs.invitationUrlButton.$el)
      Flash.success('common.copied')

    resetInvitationLink: ->
      @group.resetToken().then =>
        Flash.success('invitation_form.shareable_link_reset')

  computed:
    groupUrl: ->
      LmoUrlService.group(@group, null, { absolute: true })

    invitationLink: ->
      if @group.token
        LmoUrlService.shareableLink(@group)
      else
        @$t('common.action.loading')

    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

</script>

<template lang="pug">
v-dialog(v-model='dialog' max-width="600px")
  template(v-slot:activator="{ on }")
    v-btn.mr-2(v-on="on" color="accent" v-t="'common.action.share'")
  v-card.shareable-link-modal
    v-card-title
      h1.headline(v-t="'invitation_form.share_group'")
      v-spacer
      v-btn(icon small href="https://help.loomio.org/en/user_manual/groups/membership/" target="_blank" :title="$t('common.help')")
        v-icon mdi-help-circle-outline
      v-btn.dismiss-modal-button(icon small @click='dialog = false')
        v-icon mdi-window-close
    v-card-text
      span.subtitle-2(v-t="'invitation_form.group_url'")
      p.mt-2.mb-0.caption(v-if="group.groupPrivacy == 'secret'" v-t="'invitation_form.secret_group_url_explanation'")
      p.mt-2.mb-0.caption(v-else v-t="'invitation_form.shareable_group_url_explanation'")
      v-layout(align-center)
        v-text-field.shareable-link-modal__shareable-link(:value='groupUrl' :disabled='true')
        v-btn.shareable-link-modal__copy(ref="groupUrlButton" text color="accent" v-t="'common.copy'" v-clipboard:copy='groupUrl' v-clipboard:success='copiedGroupUrl' v-clipboard:error="error")
      div(v-if="canAddMembers")
        span.subtitle-2(v-t="'invitation_form.reusable_invitation_link'")
        p.mt-2.mb-0.caption(v-t="'invitation_form.shareable_invitation_explanation'")
        v-layout(align-center)
          v-text-field.shareable-link-modal__shareable-link(:value='invitationLink' :disabled='true')
          v-btn.shareable-link-modal__copy(ref="invitationUrlButton" text color="accent" v-t="'common.copy'" v-clipboard:copy='invitationLink' v-clipboard:success='copiedInvitationUrl' v-clipboard:error="error")
          v-btn.shareable-link-modal__reset(text color="warning" v-t="'common.reset'" @click="resetInvitationLink()")
</template>
