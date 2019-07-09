<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { applyLoadingFunction } from '@/shared/helpers/apply.coffee'

export default
  props:
    model: Object
    close: Function
  created: ->
    EventBus.$on 'versionFetching', =>
      @version = null
      @loading = true
    EventBus.$on 'versionFetched', (version) =>
      @version = version
      @loading = false
  data: ->
    version: null
    loading: false
</script>
<template lang="pug">
v-card.revision-history-modal
  v-card-title
    h1.headline(v-t="'revision_history_modal.' + model.constructor.singular + '_header'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.md-dialog-content.revision-history-modal__body
    revision-history-nav(:model='model')
    v-divider.revision-history-modal__divider
    loading(v-if='!version')
    .revision-history-modal__version(v-if='version')
      .revision-history-modal__user(v-if='!loading')
        user-avatar(:user='version.author()', size='small')
        span
          strong {{ version.authorName() }}
          span ·
          time-ago.lmo-margin-right--small(:timestamp='version.createdAt')
      revision-history-content(v-if='!loading', :model='model', :version='version')
</template>

<style lang="css">

.revision-history-modal__thread-details {
}

.revision-history-modal__divider {
  margin: 8px 0;
}

.revision-history-modal__user {
  margin-bottom: 16px;
}
</style>
