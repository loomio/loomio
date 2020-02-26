<script lang="coffee">
import { startCase } from 'lodash'

export default
  props:
    group: Object
    close: Function
  computed:
    expiresAt: ->
      @exactDate(@group.subscriptionExpiresAt)
    planName: ->
      startCase(@group.subscriptionPlan)
    planStatus: ->
      startCase(@group.subscriptionState)
</script>
<template lang="pug">
v-card.mt-2(outlined)
  v-card-title
    h1.headline(v-t="'group_page.options.subscription_status'")
    v-spacer
    v-btn.dismiss-modal-button(icon small @click="close")
      v-icon mdi-window-close
  div.ml-8.my-4
    p(v-t="{ path: 'subscription_status.plan', args: { name: planName }}")
    p(v-t="{ path: 'subscription_status.state', args: { state: planStatus }}")
    p(v-if="group.subscriptionPlan == 'trial'" v-t="{ path: 'subscription_status.expires_at', args: { date: expiresAt } }")
    p(v-t="{ path: 'subscription_status.active_members', args: { count: group.orgMembersCount }}")
    p(v-if="group.subscriptionMaxMembers" v-t="{ path: 'subscription_status.max_members', args: { count: group.subscriptionMaxMembers }}")
    p(v-if="group.subscriptionMaxThreads" v-t="{ path: 'subscription_status.max_threads', args: { count: group.subscriptionMaxThreads }}")
  v-card-actions
    v-btn(color="accent" href="https://help.loomio.org/en/subscriptions/" target="_blank" v-t="'common.help'")
    v-spacer
    v-btn(color="primary" href="/upgrade" target="_blank") Upgrade
</template>
