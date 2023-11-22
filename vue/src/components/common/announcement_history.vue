<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import utils          from '@/shared/record_store/utils';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import AbilityService from '@/shared/services/ability_service';
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import Flash   from '@/shared/services/flash';
import { encodeParams } from '@/shared/helpers/encode_params';

export default {
  props: {
    close: Function,
    model: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      historyData: [],
      historyLoading: false,
      historyError: false
    };
  },

  created() {
    this.historyLoading = true;
    Records.fetch({
      path: 'announcements/history',
      params: this.model.namedId()}).
    then(data => {
      this.historyLoading = false;
      return this.historyData = data || [];
    }
    , err => {
      this.historyLoading = false;
      return this.historyError = true;
    });
  },

  computed: {
    modelKind() { return this.model.constructor.singular; },
    pollType() { return this.model.pollType; },
    translatedPollType() {
      if (this.model.isA('poll') || this.model.isA('outcome')) {
        return this.model.poll().translatedPollType(); 
      }
    }
  }
};
</script>

<template>

<v-card>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'announcement.' + modelKind + '_notification_history'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-layout justify-center="justify-center">
    <v-progress-circular color="primary" v-if="historyLoading" indeterminate="indeterminate"></v-progress-circular>
  </v-layout>
  <v-card-text v-if="!historyLoading">
    <p v-if="historyError && historyData.length == 0" v-t="'announcement.history_error'"></p>
    <p v-if="!historyError && historyData.length == 0" v-t="'announcement.no_notifications_sent'"></p>
    <p v-if="historyData.length" v-t="'announcement.notification_history_explanation'"></p>
    <div v-for="event in historyData" :key="event.id">
      <h4 class="mt-4 mb-2">
        <time-ago :date="event.created_at"></time-ago>
        <mid-dot></mid-dot><span v-t="{ path: 'announcement.'+event.kind, args: { name: event.author_name, length: event.notifications.length } }"></span>
      </h4>
      <ul style="list-style-type: none; padding-left: 0">
        <li v-for="notification in event.notifications" :key="notification.id"><span>{{notification.to}}</span>
          <space></space><span v-if="notification.viewed">✓</span>
        </li>
      </ul>
    </div>
  </v-card-text>
</v-card>
</template>
