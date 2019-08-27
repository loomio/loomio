<script lang="coffee">
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import AuthModalMixin  from '@/mixins/auth_modal'
import Session from '@/shared/services/session'

import _isEmpty     from 'lodash/isEmpty'

export default
  mixins: [AuthModalMixin]
  data: ->
    group: null
  mounted: ->
    if Session.isSignedIn()
      @init()
    else
      @openAuthModal()
  methods:
    init: ->
      @group = Records.groups.build
        name: @$route.params.name
        customFields:
          pending_emails: _.compact((@$route.params.pending_emails || "").split(','))
</script>

<template lang="pug">
v-container.max-width-800.start-group-page
  group-new-form(:group='group')
</template>
