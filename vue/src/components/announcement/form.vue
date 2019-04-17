<style lang="scss">
@import 'variables';
.announcement-form__checkbox {
  margin: 16px 0;
}

.announcement-form__list-item,
.announcement-form__invited {
  padding: 0 !important;
}

.announcement-form__copy {
  margin-bottom: 8px;
}

.announcement-form__invite {
  margin-bottom: 16px;
}

.announcement-form__shareable-link,
.announcement-form__help {
  margin: 8px 0;
}

.announcement-form__audience {
  height: 42px;
  min-height: 42px;
  margin-bottom: 8px;
  color: $primary-text-color;
  i { opacity: 0.8; }
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import ModalService   from '@/shared/services/modal_service'
import EventBus       from '@/shared/services/event_bus'
import utils          from '@/shared/record_store/utils'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import { audiencesFor, audienceValuesFor } from '@/shared/helpers/announcement'
import _each from 'lodash/each'
import _sortBy from 'lodash/sortBy'
import _includes from 'lodash/includes'
import _map from 'lodash/map'
import _pull from 'lodash/pull'

export default {
  props:
    announcement: Object
  data: ->
    dannouncement: @announcement # does dannouncement get 'reset' when new announcement props?
    shareableLink: LmoUrlService.shareableLink(@announcement.model)
    selected: null
    query: ''
    searchResults: []
  created: ->
    if @announcement.model.isA('group')
      @announcement.model.fetchToken().then =>
        @shareableLink = LmoUrlService.shareableLink(@announcement.model)
    @dannouncement.recipients = []
    # EventBus.listen $scope, 'removeRecipient', (_event, recipient) ->
    #   _pull $scope.announcement.recipients, recipient
  methods:
    audiences: -> audiencesFor(@announcement.model)
    audienceValues: -> audienceValuesFor(@announcement.model)
    search: (query) ->
      Records.announcements.search(query, @announcement.model).then (users) =>
        @searchResults = utils.parseJSONList(users)
    buildRecipientFromEmail: (email) ->
      email: email
      emailHash: email
      avatarKind: 'mdi-email-outline'

    copied: ->
      Flash.success('common.copied')

    addRecipient: (recipient) ->
      return unless recipient
      _each recipient.emails, (email) => @addRecipient buildRecipientFromEmail(email)
      if !recipient.emails && !_includes(_map(@announcement.recipients, "emailHash"), recipient.emailHash)
        @announcement.recipients.unshift recipient
      @selected = undefined
      @query = ''

    loadAudience: (kind) ->
      Records.announcements.fetchAudience(@announcement.model, kind).then (data) =>
        _each _sortBy(utils.parseJSONList(data), (e) => e.name || e.email ), @addRecipient
  computed:
    canUpdateAnyoneCanParticipate: ->
      @announcement.model.isA('poll') &&
      AbilityService.canAdminister(@announcement.model)
  watch:
    query: (newQuery, oldQuery) ->
      if newQuery.length > 3
        @search newQuery
}
</script>

<template>
  <div class="announcement-form">
    <div class="announcement-form__invite">
      <p v-t="'announcement.form.' + announcement.kind + '.helptext'" class="announcement-form__help md-subhead"></p>
      <v-list>
        <v-list-tile v-for="audience in audiences()" :key="audience" @click="loadAudience(audience)" class="announcement-form__audience md-whiteframe-1dp">
          <i class="mdi mdi-18px mdi-account-multiple lmo-margin-right--small"></i>
          <span v-t="{ path: 'announcement.audiences.' + audience, args: audienceValues() }" class="md-body-1"></span>
        </v-list-tile>
        <v-autocomplete v-model="query" md-autoselect="true" :autofocus="true" @change="addRecipient(recipient)" item-text="email" :placeholder="$t('announcement.form.placeholder')" :items="searchResults" md-min-length="3" md-delay="150">
          <template slot="item" slot-scope="data">
            <!-- <announcement_chip user="recipient"></announcement_chip> -->
            <div>{{data}}</div>
          </template>
        </v-autocomplete>
      </v-list>
      <v-list class="announcement-form__invited">
        <div class="md-subhead announcement-form__num-notified">
          <p v-if="announcement.recipients.length == 0" v-t="'announcement.form.notified_empty'" class="lmo-text-right"></p>
          <p v-if="announcement.recipients.length == 1" v-t="'announcement.form.notified_singular'" class="lmo-text-right"></p>
          <p v-else v-t="{ path: 'announcement.form.notified', args: { notified: announcement.recipients.length } }" class="lmo-text-right"></p>
        </div>
        <v-list-tile v-for="recipient in announcement.recipients" :key="recipient.emailHash" class="announcement-form__list-item">
          <!-- <announcement_chip user="recipient" show-close="true"></announcement_chip> -->
        </v-list-tile>
      </v-list>
    </div>
    <div v-if="!announcement.model.isA('discussion') && announcement.recipients.length == 0" class="announcement-form__share-link">
      <p v-if="announcement.model.isA('group')" v-t="'invitation_form.shareable_link'" class="announcement-form__help md-subhead"></p>
      <div class="announcement-shareable-link__content lmo-flex--column">
        <div v-if="canUpdateAnyoneCanParticipate || announcement.model.anyoneCanParticipate" class="lmo-flex--row lmo-flex__center">
          <v-checkbox v-model="announcement.model.anyoneCanParticipate" @change="announcement.model.save()" v-if="canUpdateAnyoneCanParticipate" class="announcement-form__checkbox">
            <label v-t="'announcement.form.anyone_can_participate'"></label>
          </v-checkbox>
        </div>
        <div v-if="announcement.model.anyoneCanParticipate || announcement.model.isA('group')" class="lmo-flex--row lmo-flex__center">
          <div class="lmo-flex__grow md-no-errors announcement-form__shareable-link">
            <input :value="shareableLink" :disabled="true">
          </div>
          <v-btn title="$t('common.copy')" clipboard="true" text="shareableLink" on-copied="copied()" class="md-accent md-button--tiny announcement-form__copy">
            <span v-t="'common.copy'"></span>
          </v-btn>
        </div>
      </div>
    </div>
  </div>
</template>
