<script lang="coffee">
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import AuthModalMixin  from '@/mixins/auth_modal'
import Session from '@/shared/services/session'

import _isEmpty     from 'lodash/isEmpty'

export default
  mixins: [AuthModalMixin]
  mounted: ->
    @openAuthModal() unless Session.isSignedIn()
</script>

<template lang="pug">
v-container.max-width-800.start-group-page
  group-new-form
</template>
