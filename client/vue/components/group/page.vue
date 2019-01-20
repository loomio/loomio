<script lang="coffee">
import Loading from 'vue/components/common/loading.vue'
import GroupTheme from 'vue/components/group/theme.vue'
import GroupPageDescriptionCard from 'vue/components/group/description_card.vue'
import GroupPageDiscussionsCard from 'vue/components/group/discussions_card.vue'
import CurrentPollsCard from 'vue/components/group/current_polls_card.vue'
import MembershipRequestsCard from 'vue/components/group/membership_requests_card.vue'
import MembershipCard from 'vue/components/group/membership_card.vue'
import SubgroupsCard from 'vue/components/group/subgroups_card.vue'
import DocumentCard from 'vue/components/document/card.vue'
import PollCommonIndexCard from 'vue/components/poll/common/index_card.vue'

import urlFor from 'vue/mixins/url_for.coffee'

module.exports =
  mixins: [urlFor]
</script>

<template>
  <div class="loading-wrapper lmo-two-column-layout">
    <loading ng-if="!groupPage.group"></loading>
    <main ng-if="groupPage.group" class="group-page lmo-row">
      <!-- <outlet name="before-group-page" model="groupPage.group"></outlet> -->
      <group-theme :group="groupPage.group" :home-page="true"></group-theme>
      <div class="lmo-row">
        <div class="lmo-group-column-left">
          <group-page-description-card :group="groupPage.group"></group-page-description-card>
          <group-page-discussions-card :group="groupPage.group"></group-page-discussions-card>
        </div>
        <div class="lmo-group-column-right">
          <!--<outlet name="before-group-page-column-right" model="groupPage.group"></outlet>-->
          <current-polls-card :model="groupPage.group"></current-polls-card>
          <membership-request-card :group="groupPage.group"></membership-request-card>
          <membership-card :group="groupPage.group"></membership-card>
          <membership-card :group="groupPage.group" :pending="true"></membership-card>
          <subgroups-card  :group="groupPage.group"></subgroups-card>
          <document-card   :group="groupPage.group"></document-card>
          <poll-common-index-card :model="groupPage.group" :limit="5" :view-more-link="true"></poll-common-index-card>
          <!-- <outlet name="after-slack-card" model="groupPage.group"></outlet> -->
          <!-- <installslack_card group="groupPage.group"></install_slack_card> -->
        </div>
      </div>
    </main>
  </div>
</template>
