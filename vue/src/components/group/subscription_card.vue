<script lang="coffee">
import { startCase, compact } from 'lodash-es'
import parseISO from 'date-fns/parseISO'
import AbilityService from '@/shared/services/ability_service'

export default
  props:
    group: Object
  methods:
    displayDate: (dateString) -> @exactDate(parseISO(dateString))
  computed:
    referralCodeExtra: -> @$t('subscription_status.referral_code_help')
    canSee: -> !@group.parentId && AbilityService.canAdminister(@group)
    showUpgradeButton: -> @group.subscription.plan == "trial"
    isActivePlan: -> ['pp-active-monthly', 'pp-active-annual', 'pp-community-annual', 'npap-active-monthly', 'npap-active-annual'].includes(@group.subscription.plan)
    tableData: ->
      {
        plan: startCase(@group.subscription.plan)
        state: startCase(@group.subscription.state)
        expires_at: @displayDate(@group.subscription.expires_at) if @group.subscription.plan == 'trial' && @group.subscription.expires_at
        renews_at: @displayDate(@group.subscription.renews_at) if @group.subscription.renews_at
        members: @group.orgMembersCount
        active_members: @group.subscription.members_count if @isActivePlan
        max_members: @group.subscription.max_members if @group.subscription.max_members
        max_threads: @group.subscription.max_threads if @group.subscription.max_threads
        referral_code: "<strong>#{@group.subscription.referral_code}</strong> - <a href='https://help.loomio.org/en/subscriptions/referral_code/' target=_blank>#{@referralCodeExtra}</a>" if @group.subscription.referral_code
        chargify_link: "<a href=#{@group.subscription.management_link} target=_blank>#{@$t('subscription_status.manage_payment_details')}</a>" if @group.subscription.management_link
      }
</script>
<template lang="pug">
v-card.my-6(v-if="canSee" outlined)
  v-card-title
    v-icon.mr-2(color="primary") mdi-rocket
    h1.headline(tabindex="-1" v-t="'group_page.options.subscription_status'")
    v-btn.ml-2(icon small href="https://help.loomio.org/en/subscriptions/" target="_blank" :title="$t('common.help')")
      v-icon(color="accent") mdi-help-circle-outline
  div.px-6
    v-simple-table(dense)
      template(v-slot:default)
        tbody
          tr(v-for="(val, key) in tableData" :key="key" v-if="val")
            td(v-t="'subscription_status.' + key")
            td(v-html="val")
  v-card-actions(v-if="showUpgradeButton")
    v-spacer
    v-btn(color="primary" href="/upgrade" target="_blank" v-t="'current_plan_button.upgrade'")
</template>
