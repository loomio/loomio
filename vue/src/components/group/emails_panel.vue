<script lang="js">
import Records        from '@/shared/services/records';
import EventBus from "@/shared/services/event_bus";

export default
{
  data() {
    return {
      requests: [],
      group: null,
      emails: []
    };
  },

  mounted() {
    Records.groups.findOrFetch(this.$route.params.key).then(group => {
      this.group = group;

      this.watchRecords({
        key: "receivedEmails#{group.id}",
        collections: ['receivedEmails'],
        query: store => {
          this.emails = store.receivedEmails.find({groupId: this.group.id, released: false})
        }
      });

      Records.fetch({path: 'received_emails', params: {group_id: group.id }})
    });
  },

  methods: {
    allow(email) {
      EventBus.$emit('openModal', {
        component: 'MemberEmailAliasModal',
        props: {
          email: email.senderEmail,
          group: this.group,
          submit: (userId) => {
            Records.receivedEmails.remote.postMember(email.id, 'allow', {user_id: userId}).then(() => {
              EventBus.$emit('closeModal');
              Flash.success('email_to_group.email_released')
            });
          }
        }
      });
    },
    destroy(email) {
      Records.receivedEmails.destroy(email.id).then(() => {
        Flash.success('email_to_group.email_deleted')
      });
    }
  }

};
</script>
<template lang="pug">
.group-emails-panel
  h2.ma-4.headline(v-t="'email_to_group.unreleased_emails'")
  loading(v-if="!group")
  v-card.mt-4(outlined v-else="group")
    v-list(two-line)
      v-list-item(v-for="email in emails" :key="email.id")
        v-list-item-content
          v-list-item-title {{email.senderName}} <{{email.senderEmail}}>
          v-list-item-subtitle {{email.subject}}
        v-list-item-action
          v-btn.group-emails-panel__approve(text icon @click='allow(email)')
            common-icon(name="mdi-check")
        v-list-item-action
          v-btn.group-emails-panel__delete(text icon @click='destroy(email)')
            common-icon(name="mdi-close")
</template>
