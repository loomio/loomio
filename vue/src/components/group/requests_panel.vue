<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import RecordLoader   from '@/shared/services/record_loader'
import Session        from '@/shared/services/session'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import {includes, some, compact, intersection, orderBy, slice, filter, isEmpty} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  data: ->
    requests: []
    group: null

  created: ->
    Records.groups.findOrFetch(@$route.params.key).then (group) =>
      @group = group

      if AbilityService.canManageMembershipRequests(@group)
        Records.membershipRequests.fetchPendingByGroup(@group.key, per: 100)
        Records.membershipRequests.fetchPreviousByGroup(@group.key, per: 100)
        @watchRecords
          collections: ['membershipRequests']
          query: (store) =>
            @requests = @group.membershipRequests()

  computed:
    unapprovedRequestsByOldestFirst: ->
      unapproved = filter @requests, (request) -> !request.respondedAt
      orderBy unapproved, ['createdAt'], ['asc']

    approvedRequestsByNewestFirst: ->
      approved = filter @requests, (request) -> request.respondedAt
      orderBy approved, ['respondedAt'], ['desc']

</script>
<template lang="pug">
.requests-panel
  h2.ma-4.headline(v-t="'membership_requests_card.heading'")
  loading(v-if="!group")
  v-card.mt-4(outlined v-else="group")
    p.text-center.pa-4(v-if="!requests.length" v-t="'common.no_results_found'")
    v-list(two-line)
      membership-request(v-for="request in unapprovedRequestsByOldestFirst" :request="request" :key="request.id")
      membership-request(v-for="request in approvedRequestsByNewestFirst" :request="request" :key="request.id")
</template>
