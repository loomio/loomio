<script lang="coffee">
import { startCase } from 'lodash-es'
import parseISO from 'date-fns/parseISO'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    group: Object
  computed:
    canSee: ->
      AbilityService.canAdminister(@group)
    expiresAt: ->
      @exactDate(@group.subscriptionExpiresAt)
    planName: ->
      startCase(@group.subscriptionPlan)
    planStatus: ->
      startCase(@group.subscriptionState)
    renewalDate: ->
      return null unless @hasSubscriptionInfo && @group.subscriptionInfo.chargify_next_assessment_at
      @exactDate(parseISO(@group.subscriptionInfo.chargify_next_assessment_at))
    hasSubscriptionInfo: ->
      @group.subscriptionInfo
    hasReferralCode: ->
      @hasSubscriptionInfo && @group.subscriptionInfo.chargify_referral_code
    hasChargifyLink: ->
      @hasSubscriptionInfo && @group.subscriptionInfo.chargify_management_link
    tableData: ->
      {
        plan: @planName
        state: @planStatus
        expires_at: @expiresAt if @group.subscriptionPlan == 'trial'
        renews_at: @renewalDate if @renewalDate
        active_members: @group.orgMembersCount
        max_members: @group.subscriptionMaxMembers if @group.subscriptionMaxMembers
        max_threads: @group.subscriptionMaxThreads if @group.subscriptionMaxThreads
        referral_code: "<strong>#{@group.subscriptionInfo.chargify_referral_code}</strong>" if @hasReferralCode
        chargify_link: "<a href=#{@group.subscriptionInfo.chargify_management_link} target=_blank>#{@group.subscriptionInfo.chargify_management_link}</a>" if @hasChargifyLink
      }
</script>
<template lang="pug">
v-card.my-6(v-if="canSee" outlined)
  v-card-title
    v-icon.mr-2(color="primary") mdi-rocket
    h1.headline(v-t="'group_page.options.subscription_status'")
    v-btn.ml-2(icon small href="https://help.loomio.org/en/subscriptions/" target="_blank" :title="$t('common.help')")
      v-icon(color="accent") mdi-help-circle-outline
  div.px-6
    v-simple-table(dense)
      template(v-slot:default)
        tbody
          tr(v-for="(val, key) in tableData" :key="key" v-if="val")
            td(v-t="'subscription_status.' + key")
            td(v-html="val")
  v-card-actions
    v-spacer
    v-btn(color="primary" href="/upgrade" target="_blank") Upgrade
</template>
