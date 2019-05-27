<style lang="scss">
@import 'lmo_card';
.authorized-apps-page {
  @include card;
  margin-top: 16px;

  .lmo-box--small { margin-right: 12px; }
}
</style>

<script lang="coffee">
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import ModalService from '@/shared/services/modal_service'
import _sortBy   from 'lodash/sortBy'

export default {
  data: ->
    loading: true
  created: ->
    EventBus.$emit 'currentComponent', {title: 'Apps', page: 'authorizedAppsPage'}
    Records.oauthApplications.fetchAuthorized().then => @loading = false
  methods:
    applications: ->
      Records.oauthApplications.find(authorized: true)

    openRevokeForm: (application) ->
      ModalService.open 'RevokeAppForm', application: => application
  computed:
    orderedApplications: ->
      _sortBy @applications(), 'name'
}
</script>

<template>
  <div class="lmo-one-column-layout">
    <loading v-show="loading"></loading>
    <main v-if="!loading" class="authorized-apps-page">
      <h1 v-t="'authorized_apps_page.title'" class="lmo-h1"></h1>
      <hr>
      <div v-if="applications().length == 0" v-t="'authorized_apps_page.no_applications'" class="lmo-placeholder"></div>
      <div layout="column" v-if="applications().length > 0" class="lmo-flex lmo-flex__space-between">
        <div v-t="'authorized_apps_page.notice'" class="lmo-placeholder"></div>
        <div layout="row" v-for="application in orderedApplications" :key="application.id" class="lmo-flex lmo-flex__center">
          <img :src="application.logoUrl" class="lmo-box--small">
          <strong class="lmo-flex__grow">{{ application.name }}</strong>
          <v-btn @click="openRevokeForm(application)" v-t="'authorized_apps_page.revoke'" class="md-raised md-warn"></v-btn>
        </div>
      </div>
    </main>
  </div>
</template>
