<script lang="coffee">
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import ModalService  from '@/shared/services/modal_service'
import Session from '@/shared/services/session'

import _isEmpty     from 'lodash/isEmpty'

export default
  data: ->
    group: null
  mounted: ->
    EventBus.$on 'signedIn', =>
      @init()
    @init() if Session.isSignedIn()
  methods:
    init: ->
      @group = Records.groups.build
        name: @$route.params.name
        customFields:
          pending_emails: _.compact((@$route.params.pending_emails || "").split(','))
  created: ->
    EventBus.$emit 'currentComponent', { page: 'startGroupPage', skipScroll: true }
    # EventBus.listen $scope, 'nextStep', (_, group) ->
    #   LmoUrlService.goTo LmoUrlService.group(group)
    #   ModalService.open 'InvitationModal', group: -> group
  computed:
    isEmptyGroup: ->
      _isEmpty @group
</script>

<template>
  <div class="lmo-one-column-layout">
    <main class="start-group-page lmo-row">
      <loading v-if="isEmptyGroup"></loading>
      <div v-if="!isEmptyGroup" layout="column" class="start-group-page__main-content lmo-flex lmo-card">
        <h1 v-t="'group_form.start_group_heading'" class="lmo-card-heading"></h1>
        <group-form :group="group"></group-form>
      </div>
    </main>
  </div>
</template>
