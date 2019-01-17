<script>
import Loading from 'vue/components/loading/loading.coffee'
import GroupTheme from 'vue/components/group/theme/group_theme.coffee'
import GroupPageDescriptionCard from 'vue/components/group/page/description_card/group_page_description_card.coffee'
import GroupPageDiscussionsCard from 'vue/components/group/page/discussions_card/group_page_discussions_card.coffee'
import CurrentPollsCard from 'vue/components/current_polls_card/current_polls_card.coffee'
import MembershipRequestsCard from 'vue/components/group/page/membership_requests_card/membership_requests_card.coffee'
import MembershipCard from 'vue/components/group/page/membership_card/membership_card.coffee'
import SubgroupsCard from 'vue/components/group/page/subgroups_card/subgroups_card.coffee'
import DocumentCard from 'vue/components/document/card/document_card.coffee'
import PollCommonIndexCard from 'vue/components/poll_common_index_card/membership_card.coffee'

import urlFor from 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
</script>

<template>
  hello I'm the group page
</template>

<femplate>
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
  </femplate>
