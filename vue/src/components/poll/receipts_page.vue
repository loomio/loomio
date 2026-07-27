<script setup>
import Records       from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import { I18n } from '@/i18n';
import { mdiCheck, mdiClose } from '@mdi/js';

import { ref, defineProps } from 'vue';
const receipts = ref([]);
const voters_count = ref(0);
const { id } = defineProps({ id: String });

const headers = ref(
  [
    { title: I18n.global.t('poll_receipts_page.voter_name'), key: 'voter_name' },
    { title: I18n.global.t('poll_receipts_page.member_since'), key: 'member_since' },
    { title: I18n.global.t('poll_receipts_page.invited_by'), key: 'inviter_name' },
    { title: I18n.global.t('poll_receipts_page.invited_on'), key: 'invited_on' },
    { title: I18n.global.t('poll_receipts_page.vote_cast'), key: 'vote_cast' }
  ]
);

Records.fetch({ path: `/polls/${id}/receipts` }).then(data => {
  receipts.value = data.receipts;
  voters_count.value = data.voters_count;
  if (data.show_voter_email) {
    headers.value.splice(1, 0, {
      title: I18n.global.t('poll_receipts_page.voter_email'),
      key: 'voter_email'
    });
  }
  EventBus.$emit('currentComponent', {
    title: data.poll_title,
  });
});


</script>

<template lang="pug">
.poll-page
  v-main
    v-container
      h1.text-headline-large.pa-4(v-t="'poll_receipts_page.verify_participants'")
      p.font-italic.px-4.pb-4(v-t="'poll_receipts_page.participation_records_explanation'")

      v-alert(type="error" v-if="voters_count > 0 && receipts.length == 0 " v-t="'poll_receipts_page.no_receipts'")

      v-data-table(density="compact" :items="receipts" :headers="headers" :items-per-page="-1" hide-default-footer)
        template(v-slot:[`item.vote_cast`]="{ value }")
          v-icon(
            v-if="value === true"
            :icon="mdiCheck"
            color="success"
            size="small"
            :aria-label="$t('poll_receipts_page.voted')"
          )
          v-icon(
            v-else
            :icon="mdiClose"
            color="error"
            size="small"
            :aria-label="$t('poll_receipts_page.not_voted')"
          )
</template>
