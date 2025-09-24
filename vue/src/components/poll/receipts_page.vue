<script setup>
import Records       from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';

import { ref, defineProps } from 'vue';
const receipts = ref([]);
const { id } = defineProps({ id: String });

Records.fetch({ path: `/polls/${id}/receipts` }).then(data => {
  receipts.value = data.receipts;
  EventBus.$emit('currentComponent', {
    title: data.poll_title,
  });
});


</script>

<template lang="pug">
.poll-page
  v-main
    v-container
      h1.text-h4.pa-4(v-t="'poll_receipts_page.verify_participants'")
      p.font-italic.px-4.pb-4(v-t="'poll_receipts_page.see_votes_if_quorum_reached'")

      v-table(density="compact")
        thead
          tr
            th(v-t="'poll_receipts_page.voter_name'")
            th(v-t="'poll_receipts_page.voter_email'")
            th(v-t="'poll_receipts_page.vote_cast'")
            th(v-t="'poll_receipts_page.member_since'")
            th(v-t="'poll_receipts_page.invited_by'")
            th(v-t="'poll_receipts_page.invited_on'")
        tbody
          tr(v-for="r in receipts")
            td {{ r.voter_name }}
            td {{ r.voter_email || r.voter_email_domain }}
            td {{ r.vote_cast }}
            td {{ r.member_since }}
            td {{ r.inviter_name }}
            td {{ r.invited_on }}
</template>
