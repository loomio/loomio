<script lang="js">
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import Session        from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';

import { map, sortBy, head } from 'lodash-es';
import { format, formatDistance, parse, startOfHour, isValid, addHours, isAfter, parseISO } from 'date-fns';
import { exact} from '@/shared/helpers/format_time';

import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import { I18n } from '@/i18n';
import { mdiCalendar } from '@mdi/js';

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
      mdiCalendar,
      loading: false,
      options: [],
      bestOption: null,
      isDisabled: false,
      review: false,
      isShowingDatePicker: false,
      dateToday: new Date(),
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
        value: I18n.global.t('common.none'),
        attendees: 0
      });

      this.bestOption = head(sortBy(this.options, option => -1 * option.attendees)
      ); // sort descending, so the best option is first

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
      this.loading = true;
      if (this.poll.datesAsOptions()) { this.outcome.eventDescription = this.outcome.statement; }
      if (this.poll.pollType == 'meeting') { this.outcome.includeActor = 1; }

      if (this.outcome.isNew()) {
        actionName = "created";
      } else {
        actionName = "updated";
      }

      this.outcome.save().then(data => {
        Flash.success(`poll_common_outcome_form.outcome_${actionName}`);
        EventBus.$emit('closeModal');
      }).catch((err) => {
        Flash.error('poll_common_form.please_review_the_form');
        console.log(err);

      }).finally(() => this.loading = false);
    },

    newRecipients(val) {
      this.recipients = val;
      this.outcome.recipientAudience = (val.find(i => i.type === 'audience') || {}).id;
      this.outcome.recipientUserIds = map(filter(val, o => o.type === 'user'), 'id');
      this.outcome.recipientEmails = map(filter(val, o => o.type === 'email'), 'name');
    }
  }
};

</script>

<template lang="pug">
v-card.poll-common-outcome-modal(
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
  :title="outcome.isNew() ? $t('poll_common_outcome_form.new_title') : $t('poll_common_outcome_form.update_title')"
)
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.poll-common-outcome-form
    p.pb-4.text-medium-emphasis(v-t="'announcement.form.outcome_announced.helptext'")
    recipients-autocomplete(
      :label="$t('action_dock.notify')"
      :placeholder="$t('poll_common_outcome_form.who_to_notify')"
      :include-actor="outcome.poll().pollType == 'meeting'"
      :model="outcome")

    .poll-common-calendar-invite(v-if='poll.datesAsOptions()')
      .poll-common-calendar-invite__form
        .poll-common-calendar-invite--pad-top
          v-select.lmo-flex__grow(
            v-model='outcome.pollOptionId'
            :items="options"
            item-value="id"
            item-title="value"
            :label="$t('poll_common_calendar_invite.poll_option_id')")
        .poll-common-calendar-invite--pad-top(v-if='outcome.pollOptionId')
          v-text-field.poll-common-calendar-invite__summary(
            v-model='outcome.eventSummary'
            type='text'
            :placeholder="$t('poll_common_calendar_invite.event_summary_placeholder')"
            :label="$t('poll_common_calendar_invite.event_summary')")
          validation-errors(:subject='outcome' field='event_summary')
          v-text-field.poll-common-calendar-invite__location(
            v-model='outcome.eventLocation'
            type='text'
            :placeholder="$t('poll_common_calendar_invite.location_placeholder')"
            :label="$t('poll_common_calendar_invite.location')")

    .outcome-review-on(v-if="outcome.poll().pollType == 'proposal'")
      lmo-date-input(
        :label="$t('poll_common_outcome_form.review_date')"
        :hint="$t('poll_common_outcome_form.review_date_hint')"
        v-model='outcome.reviewOn'
        :prepend-inner-icon="mdiCalendar"
        :min="dateToday"
        clearable
        @click:clear="outcome.reviewOn = null"
        hide-actions
      )

    lmo-textarea.poll-common-outcome-form__statement.mt-4(:model='outcome' field='statement' :label="$t('poll_common.statement')" :placeholder="$t('poll_common_outcome_form.statement_placeholder')")
      template(v-slot:actions)
        v-btn.poll-common-outcome-form__submit(color="primary" @click='submit()' :loading="loading")
          span(v-t="'poll_common.post_outcome'")
    validation-errors(:subject="outcome" field="statement")
</template>
