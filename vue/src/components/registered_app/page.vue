<style lang="scss">
@import 'lmo_card';
@import 'mixins';
.registered-app-page {
  @include card;
  margin-top: 16px;
  h3 { margin-bottom: 0; }
}

.registered-app-page__app {
  margin: 16px 0;
}

.registered-app-page__title {
  margin-bottom: 16px;
}

.registered-app-page__code {
  background: $background-color;
  padding: 8px;
  @include roundedCorners;
  @include truncateText;
}
</style>

<script lang="coffee">
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import Flash from '@/shared/services/flash'
import ModalService from '@/shared/services/modal_service'

import _isEmpty     from 'lodash/isEmpty'

export default
  data: ->
    application: {}
  created: ->
    @setApplication Records.oauthApplications.find parseInt(@$route.params.id)
    Records.oauthApplications.findOrFetchById(parseInt(@$route.params.id)).then @setApplication, (error) ->
      EventBus.$emit 'pageError', error
  methods:
    setApplication: (application) ->
      if application and isEmptyApplication?
        @application = application
        EventBus.$emit 'currentComponent', { title: application.name, page: 'oauthApplicationPage'}

    copied: ->
      Flash.success('common.copied')

    openRemoveForm: ->
      ModalService.open 'RemoveAppForm', application: => @application

    openEditForm: ->
      ModalService.open 'RegisteredAppForm', application: => @application
  computed:
    isEmptyApplication: ->
      _isEmpty @application
</script>

<template>
  <div class="lmo-one-column-layout">
    <loading v-if="isEmptyApplication"></loading>
    <main v-if="!isEmptyApplication" class="registered-app-page">
      <div layout="column" class="lmo-flex registered-app-page__app">
        <div layout="row" class="lmo-flex lmo-flex__center registered-app-page__title">
          <img :src="application.logoUrl" class="lmo-box--small lmo-margin-right">
          <h1 class="lmo-h1">{{ application.name }}</h1>
        </div>
        <h3 v-t="'registered_app_page.uid'" class="lmo-h3"></h3>
        <div layout="row" class="registered-app-page__field lmo-flex lmo-flex__center">
          <code class="registered-app-page__code lmo-flex__grow">{{ application.uid }}</code>
          <v-btn title="$t('common.copy')" clipboard="true" :text="application.uid" :on-copied="copied()">
            <span v-t="'common.copy'"></span>
          </v-btn>
        </div>
        <h3 v-t="'registered_app_page.secret'" class="lmo-h3"></h3>
        <div layout="row" class="registered-app-page__field lmo-flex lmo-flex__center">
          <code class="registered-app-page__code lmo-flex__grow">{{ application.secret }}</code>
          <v-btn title="$t('common.copy')" clipboard="true" :text="application.secret" :on-copied="copied()">
            <span v-t="'common.copy'"></span>
          </v-btn>
        </div>
        <h3 v-t="'registered_apps_page.redirect_uris'" class="lmo-h3"></h3>
        <div layout="row" v-for="uri in application.redirectUriArray()" class="registered-app-page__field lmo-flex lmo-flex__center">
          <code class="registered-app-page__code lmo-flex__grow">{{ uri }}</code>
          <v-btn title="$t('common.copy')" clipboard="true" text="uri" :on-copied="copied()">
            <span v-t="'common.copy'"></span>
          </v-btn>
        </div>
      </div>
      <div class="lmo-flex lmo-flex__space-between">
        <div>
          <router-link to="/apps/registered" class="md-button">
            <span v-t="'common.action.back'"></span>
          </router-link>
        </div>
        <div>
          <v-btn type="button" v-t="'common.action.remove'" @click="openRemoveForm()" class="md-warn md-raised"></v-btn>
          <v-btn type="button" v-t="'common.action.edit'" @click="openEditForm()" class="md-primary md-raised"></v-btn>
        </div>
      </div>
    </main>
  </div>
</template>
