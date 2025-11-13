<script lang="js">
import OutcomeService from '@/shared/services/outcome_service';
import parseISO from 'date-fns/parseISO';
import { pickBy } from 'lodash-es';
import Session    from '@/shared/services/session';
import FormatDate from '@/mixins/format_date';

export default {
  mixins: [FormatDate],
  props: {
    outcome: Object
  },

  methods: {
    parseISO,
    viewed(seen) {
      if (seen &&
          Session.isSignedIn() &&
          Session.user().autoTranslate &&
          this.dockActions['translate_outcome'].canPerform()) {
        this.dockActions['translate_outcome'].perform();
      }
    },
  },
  computed: {
    menuActions() {
      return pickBy(OutcomeService.actions(this.outcome, this), (v, k) => v.menu);
    },
    dockActions() {
      return pickBy(OutcomeService.actions(this.outcome, this), (v, k) => v.dock > 0);
    }
  }
};

</script>

<template lang="pug">
v-alert.my-4.poll-common-outcome-panel(
  v-if="outcome"
  color="info"
  variant="tonal"
  v-intersect.once="{handler: viewed}"
)
  h2.text-h6(v-t="'poll_common.outcome'")
  div.my-2
    user-avatar(:user="outcome.author()", :size="24").mr-2
    space
    //- .poll-common-outcome-panel__authored-by.text-caption.my-2
    span(v-t="{ path: 'poll_common_outcome_panel.authored_by', args: { name: outcome.authorName() } }")
    mid-dot
    time-ago(:date="outcome.createdAt")
    template(v-if="outcome.reviewOn")
      mid-dot
      span(v-t="'poll_common.review_due'")
      space
      time-ago(:date="outcome.reviewOn")
  .poll-common-outcome__event-info(v-if="outcome.poll().datesAsOptions() && outcome.pollOption()")
    .text-h6 {{outcome.eventSummary}}
    span {{exactDate(parseISO(outcome.pollOption().name))}}
    p {{outcome.eventLocation}}
  formatted-text.text-on-surface(:model="outcome" field="statement")
  link-previews(:model="outcome")
  document-list(:model="outcome")
  attachment-list(:attachments="outcome.attachments")
  action-dock(:model="outcome" :actions="dockActions" :menuActions="menuActions")
</template>
