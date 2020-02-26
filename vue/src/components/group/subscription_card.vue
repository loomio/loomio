<script lang="coffee">
import { startCase } from 'lodash'

export default
  props:
    group: Object
    close: Function
  computed:
    planName: ->
      startCase(@group.subscriptionPlan)
    planStatus: ->
      startCase(@group.subscriptionState)
</script>
<template lang="pug">
v-card.mt-2(outlined)
  v-card-title
    h1.headline Subscription Details
    v-spacer
    v-btn(icon small href="https://help.loomio.org/en/subscriptions/" target="_blank" :title="$t('common.help')")
      v-icon mdi-help-circle-outline
    v-btn.dismiss-modal-button(icon small @click="close")
      v-icon mdi-window-close
  v-card-text
    p Plan: {{planName}}
    p Status: {{planStatus}}
    p Active members: {{group.orgMembersCount}}
    p(v-if="group.subscriptionMaxMembers") Max members: {{group.subscriptionMaxMembers}}
    p(v-if="group.subscriptionMaxThreads") Max threads: {{group.subscriptionMaxThreads}}
  v-card-actions
    v-btn(color="accent" href="https://help.loomio.org/en/subscriptions/" target="_blank" v-t="'common.help'")
    v-spacer
    v-btn(color="primary" href="/upgrade" target="_blank") Upgrade
</template>
