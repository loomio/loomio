<style lang="scss">
@import 'lmo_card';
@import 'mixins';
.registered-apps-page {
  @include card;
  margin-top: 16px;
}

.registered-apps-page__apps {
  width: 100%;
}

.registered-apps-page__code {
  max-width: 300px;
  @include truncateText;
}

.registered-apps-page__clear {
  min-width: 32px;
}
</style>

<script lang="coffee">
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import ModalService from '@/shared/services/modal_service'
import UrlFor       from '@/mixins/url_for'

import _sortBy   from 'lodash/sortBy'

export default
  mixins: [UrlFor]
  data: ->
    loading: true
    applications: Records.oauthApplications.collection.data
  created: ->
    EventBus.$emit 'currentComponent', {title: 'OAuth Application Dashboard', page: 'registeredAppsPage'}
    Records.oauthApplications.fetchOwned().then => @loading = false
  methods:
    openApplicationForm: (application) ->
      ModalService.open 'RegisteredAppForm', application: => Records.oauthApplications.build()

    openDestroyForm: (application) ->
      ModalService.open 'RemoveAppForm', application: => application
  computed:
    orderedApplications: ->
      _sortBy @applications, 'name'
</script>

<template>
  <div class="lmo-one-column-layout">
    <loading v-show="loading"></loading>
    <main v-if="!loading" class="registered-apps-page">
      <div class="lmo-flex lmo-flex__space-between">
        <h1 v-t="'registered_apps_page.title'" class="lmo-h1"></h1>
        <v-btn @click="openApplicationForm()" class="md-primary md-raised">
          <span v-t="'registered_apps_page.create_new_application'"></span>
        </v-btn>
      </div>
      <div v-if="applications.length == 0" v-t="'registered_apps_page.no_applications'" class="lmo-placeholder"></div>
      <div layout="column" v-if="applications.length > 0" class="lmo-flex">
        <div layout="row" v-for="application in orderedApplications" :key="application.id" class="registered-apps-page__apps lmo-flex lmo-flex__center">
          <img :src="application.logoUrl" class="lmo-box--medium lmo-margin-right">
          <div class="lmo-flex__grow">
            <strong><router-link :to="urlFor(application)" class="nowrap">{{ application.name }}</router-link></strong>
          </div>
          <code v-for="uri in application.redirectUriArray()" class="registered-apps-page__code lmo-flex__grow">{{uri}}</code>
          <v-btn @click="openDestroyForm(application)" class="registered-apps-page__clear lmo-flex lmo-flex__center lmo-flex__horizontal-center">
            <div class="mdi mdi-close"></div>
          </v-btn>
        </div>
      </div>
    </main>
  </div>
</template>
