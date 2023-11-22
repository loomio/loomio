<script lang="js">
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import Session        from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';

import Vue     from 'vue';
import { map, sortBy, head } from 'lodash-es';
import { format, formatDistance, parse, startOfHour, isValid, addHours, isAfter, parseISO } from 'date-fns';
import { exact} from '@/shared/helpers/format_time';

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import I18n from '@/i18n';

export default {
  components: {
    RecipientsAutocomplete
  },

  props: {
    outcome: Object,
    close: Function
  },

  data() {
    return {
      options: [],
      bestOption: null,
      isDisabled: false,
      review: false,
      isShowingDatePicker: false,
      dateToday: format(new Date, 'yyyy-MM-dd')
    };
  },

  created() {
    if (this.poll.datesAsOptions()) {
      this.options = map(this.outcome.poll().pollOptions(), option => ({
        id:        option.id,
        value:     exact(parseISO(option.name)),
        attendees: option.stances().length
      }));

      this.options.unshift({
        id: null,
        value: I18n.t('common.none'),
        attendees: 0
      });

      this.bestOption = head(sortBy(this.options, option => -1 * option.attendees)
      ); // sort descending, so the best option is first

      Vue.set(this.outcome, 'calendarInvite', true);

      this.outcome.pollOptionId = this.outcome.pollOptionId || this.bestOption.id;
      this.outcome.eventSummary = this.outcome.eventSummary || this.outcome.poll().title;
    }
  },
    
  computed: {
    poll() { return this.outcome.poll(); }
  },

  methods: {
    submit() {
      let actionName;
      if (this.poll.datesAsOptions()) { this.outcome.eventDescription = this.outcome.statement; }
      if (this.outcome.calendarInvite) { this.outcome.includeActor = 1; }

      if (this.outcome.isNew()) {
        actionName = "created";
      } else {
        actionName = "updated";
      }

      this.outcome.save().then(data => {
        Flash.success(`poll_common_outcome_form.outcome_${actionName}`);
        return this.closeModal();
      }).catch(error => true);
    },

    newRecipients(val) {
      this.recipients = val;
      this.outcome.recipientAudience = (val.find(i => i.type==='audience') || {}).id;
      this.outcome.recipientUserIds = map(filter(val, o => o.type === 'user'), 'id');
      this.outcome.recipientEmails = map(filter(val, o => o.type === 'email'), 'name');
    }
  }
};

</script>

<template>

<v-card class="poll-common-outcome-modal" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()">
  <submit-overlay :value="outcome.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline"><span v-if="outcome.isNew()" v-t="'poll_common_outcome_form.new_title'"></span><span v-if="!outcome.isNew()" v-t="'poll_common_outcome_form.update_title'"></span></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :model="outcome"></dismiss-modal-button>
  </v-card-title>
  <div class="poll-common-outcome-form px-4">
    <p class="text--secondary" v-t="'announcement.form.outcome_announced.helptext'"></p>
    <recipients-autocomplete :label="$t('action_dock.notify')" :placeholder="$t('poll_common_outcome_form.who_to_notify')" :include-actor="outcome.calendarInvite" :model="outcome"></recipients-autocomplete>
    <div class="poll-common-calendar-invite" v-if="poll.datesAsOptions()">
      <div class="poll-common-calendar-invite__form">
        <div class="poll-common-calendar-invite--pad-top">
          <v-select class="lmo-flex__grow" v-model="outcome.pollOptionId" :items="options" item-value="id" item-text="value" :label="$t('poll_common_calendar_invite.poll_option_id')"></v-select>
        </div>
        <div class="poll-common-calendar-invite--pad-top" v-if="outcome.pollOptionId">
          <v-text-field class="poll-common-calendar-invite__summary" v-model="outcome.eventSummary" type="text" :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')" :label="$t('poll_common_calendar_invite.event_summary')"></v-text-field>
          <validation-errors :subject="outcome" field="event_summary"></validation-errors>
          <v-text-field class="poll-common-calendar-invite__location" v-model="outcome.eventLocation" type="text" :placeholder="$t('poll_common_calendar_invite.location_placeholder')" :label="$t('poll_common_calendar_invite.location')"></v-text-field>
        </div>
      </div>
    </div>
    <div class="outcome-review-on" v-if="outcome.poll().pollType == 'proposal'">
      <v-menu ref="menu" v-model="isShowingDatePicker" :close-on-content-click="false" offset-y="offset-y" min-width="290px">
        <template v-slot:activator="{ on, attrs }">
          <v-text-field clearable="clearable" v-model="outcome.reviewOn" placeholder="2050-12-31" :label="$t('poll_common_outcome_form.review_date')" :hint="$t('poll_common_outcome_form.review_date_hint')" v-on="on" v-bind="attrs" prepend-icon="mdi-calendar"></v-text-field>
        </template>
        <v-date-picker class="outcome-review-on__datepicker" v-model="outcome.reviewOn" :min="dateToday" no-title="no-title" @input="isShowingDatePicker = false"></v-date-picker>
      </v-menu>
      <p v-if="outcome.reviewOn" v-t="$t('poll_common_outcome_form.you_will_be_notified')"></p>
    </div>
    <lmo-textarea class="poll-common-outcome-form__statement lmo-primary-form-input" :model="outcome" field="statement" :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')">
      <template v-slot:actions="v-slot:actions">
        <v-btn class="poll-common-outcome-form__submit" color="primary" @click="submit()" :loading="outcome.processing"><span v-t="'common.action.save'"></span></v-btn>
      </template>
    </lmo-textarea>
    <validation-errors :subject="outcome" field="statement"></validation-errors>
  </div>
</v-card>
</template>
