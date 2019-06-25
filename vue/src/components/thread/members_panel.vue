<script lang="coffee">
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import WatchRecords from '@/mixins/watch_records'
import RecordLoader   from '@/shared/services/record_loader'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [WatchRecords]
  data: ->
    discussion: null
    memberships: []
    loader: null
  created: ->
    @discussion = Records.discussions.find(@$route.params.key)
    @loader = new RecordLoader
      collection: 'memberships'
      params:
        per: 25
        group_id: @discussion.guestGroupId
    @loader.fetchRecords()
    @watchRecords
      collections: ['memberships']
      query: (store) =>
        @memberships = store.memberships.collection.chain()
          .find(groupId: @discussion.guestGroupId)
          .compoundsort([['admin', true], ['acceptedAt'], ['createdAt', true]])
          .data()

</script>

<template lang="pug">
.thread-members-panel
  v-list(two-line)
    v-list-tile(v-for='membership in memberships' :key='membership.id')
      v-list-tile-avatar
        user-avatar(:user='membership.user()' size='forty' :coordinator='membership.admin' :no-link='!membership.acceptedAt')
      v-list-tile-content
        v-list-tile-title {{membership.userName() || membership.user().email }}
      v-list-tile-action
        membership-dropdown(:membership="membership")
  v-btn.thread-members-panel__show-more(v-if="!loader.exhausted" :disabled="loader.loading" @click='loader.loadMore()', v-t="{ path: 'common.action.show_more' }")
  loading(v-if="loader.loading")
</template>

<!-- ['-admin', '-createdAt'] -->
