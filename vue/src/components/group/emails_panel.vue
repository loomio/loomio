<script setup>
import { onMounted, ref } from 'vue';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const emails = ref([]);
const aliases = ref([]);
const { watchRecords } = useWatchRecords();

function fetchAliases() {
  Records.fetch({path: 'received_emails/aliases', params: {group_id: group.id}}).then(data => {
    aliases.value = data.aliases;
  });
}

function fetchEmails() {
  return Records.fetch({path: 'received_emails', params: {group_id: group.id}});
}

function userById(id) {
  return Records.users.find(id);
}

function allow(email) {
  EventBus.$emit('openModal', {
    component: 'MemberEmailAliasModal',
    props: {receivedEmail: email, group, callbackFn: fetchAliases}
  });
}

function block(email) {
  EventBus.$emit('openModal', {
    component: 'ConfirmModal',
    props: {
      confirm: {
        submit: () => Records.receivedEmails.remote.postMember(email.id, 'block').then(() => {
          EventBus.$emit('closeModal');
          Flash.success('email_to_group.email_blocked');
          fetchAliases();
        }),
        text: {
          title: 'email_to_group.confirm_block',
          helptext: 'email_to_group.confirm_block_body',
          submit: 'email_to_group.block_email'
        },
        textArgs: {sender: email.senderEmail}
      }
    }
  });
}

function destroyAlias(alias) {
  Records.remote.destroy('received_emails/destroy_alias', {id: alias.id}).then(() => {
    fetchAliases();
    fetchEmails();
  });
}

onMounted(() => {
  fetchEmails();
  fetchAliases();
  watchRecords({
    key: `receivedEmails${group.id}`,
    collections: ['receivedEmails'],
    query: () => {
      emails.value = Records.receivedEmails.find({groupId: group.id, released: false});
    }
  });
});
</script>
<template lang="pug">
.group-emails-panel
  h2.ma-4.headline(v-t="'email_to_group.unreleased_emails'")
  loading(v-if="!group")
  v-card.mt-4(variant="outlined" v-if="group")
    v-alert.text-center.text-medium-emphasis(v-if="emails.length == 0" v-t="'email_to_group.no_emails_to_release'")
    v-list(v-else lines="two")
      v-list-item(v-for="email in emails" :key="email.id")
        v-list-item-title
          span {{email.senderName}} &lt;{{email.senderEmail}}&gt;
        v-list-item-subtitle {{email.subject}}
        template(v-slot:append)
          v-btn.group-emails-panel__approve( variant="text" icon @click='allow(email)' :title="$t('membership_requests_page.approve')")
            common-icon(name="mdi-check")
          v-btn.group-emails-panel__delete(variant="text" icon @click='block(email)' :title="$t('membership_requests_page.ignore')")
            common-icon(name="mdi-cancel")

  template(v-if="group && aliases.length")
    h2.ma-4.headline(v-t="'email_to_group.email_aliases'")
    v-card.mt-4(variant="outlined")
      v-list(lines="two")
        v-list-item(v-for="alias in aliases" :key="alias.id")
          v-list-item-title
            span {{alias.email}}
          v-list-item-subtitle
            span(v-if="alias.user_id" v-t="{path: 'email_to_group.belongs_to_name', args: {name: userById(alias.user_id).name}}")
            span(v-if="!alias.user_id" v-t="'membership_requests_page.ignore'")
            mid-dot
            time-ago(:date='alias.created_at')
          template(v-slot:append)
            v-btn.group-emails-panel__delete(variant="text" icon @click='destroyAlias(alias)' title="destroy")
              common-icon(name="mdi-delete")
</template>
