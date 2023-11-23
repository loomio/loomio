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

    block(email) {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: () => {
              Records.receivedEmails.remote.postMember('block', email.id).then(() => {
                EventBus.$emit('closeModal');
                Flash.success('email_to_group.email_blocked')
              });
            },
            text: {
              title:    'email_to_group.confirm_block',
              helptext: 'email_to_group.confirm_block_body',
              submit:   'email_to_group.block_email'
            },
            textArgs: {
              sender: email.senderEmail
            }

          }
        }
      });
    },

    destroy(email) {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: () => {
              Records.receivedEmails.remote.destroy(email.id).then(() => {
                EventBus.$emit('closeModal');
                Flash.success('email_to_group.email_deleted')
              });
            },
            text: {
              title:    'email_to_group.confirm_delete',
              helptext: 'email_to_group.confirm_delete_body',
              submit:   'common.action.delete'
            },
            textArgs: {
              sender: email.senderEmail
            }
          }
        }
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
          v-btn.group-emails-panel__approve(text icon @click='allow(email)' title="approve")
            common-icon(name="mdi-check")
        v-list-item-action
          v-btn.group-emails-panel__approve(text icon @click='destroy(email)' title="delete")
            common-icon(name="mdi-delete")
        v-list-item-action
          v-btn.group-emails-panel__delete(text icon @click='block(email)' title="block")
            common-icon(name="mdi-cancel")
</template>
