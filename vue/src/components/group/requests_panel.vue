<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import Session        from '@/shared/services/session'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import {includes, some, compact, intersection, orderBy, slice, filter, isEmpty} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  data: ->
    requests: []
    group: Records.groups.fuzzyFind(@$route.params.key)
  created: ->
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
  v-list(two-line)
    membership-request(v-for="request in unapprovedRequestsByOldestFirst" :request="request" :key="request.id")
    membership-request(v-for="request in approvedRequestsByNewestFirst" :request="request" :key="request.id")
</template>
