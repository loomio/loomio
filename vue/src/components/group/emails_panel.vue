<script lang="js">
import Records  from '@/shared/services/records';
import EventBus from "@/shared/services/event_bus";
import Flash from "@/shared/services/flash";
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default
{
  mixins: [WatchRecords, UrlFor],
  data() {
    return {
      requests: [],
      group: null,
      emails: [],
      aliases: []
    };
  },

  mounted() {
    Records.groups.findOrFetch(this.$route.params.key).then(group => {
      this.group = group;

      this.fetchEmails();
      this.fetchAliases();

      this.watchRecords({
        key: "receivedEmails#{group.id}",
        collections: ['receivedEmails'],
        query: store => {
          this.emails = store.receivedEmails.find({groupId: this.group.id, released: false})
        }
      });
    });
  },

  methods: {
    fetchAliases() {
      Records.fetch({path: 'received_emails/aliases', params: {group_id: this.group.id}}).then(data => {
        this.aliases = data.aliases
      })
    },

    fetchEmails() {
      Records.fetch({path: 'received_emails', params: {group_id: this.group.id }})
    },

    userById(id) {
      return Records.users.find(id)
    },

    allow(email) {
      EventBus.$emit('openModal', {
        component: 'MemberEmailAliasModal',
        props: {
          receivedEmail: email,
          group: this.group,
          callbackFn: () => {
            this.fetchAliases();
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
              return Records.receivedEmails.remote.postMember(email.id, 'block').then(() => {
                EventBus.$emit('closeModal');
                Flash.success('email_to_group.email_blocked')
                this.fetchAliases();
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

    destroyAlias(alias) {
      Records.remote.destroy('received_emails/destroy_alias', {id: alias.id}).then(() => {
        this.fetchAliases();
        this.fetchEmails();
      })
    },
  }

};
</script>
<template lang="pug">
.group-emails-panel
  h2.ma-4.text-headline-small(v-t="'email_to_group.unreleased_emails'")
  loading(v-if="!group")
  v-card.mt-4(outlined v-if="group")
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
    h2.ma-4.text-headline-small(v-t="'email_to_group.email_aliases'")
    v-card.mt-4(outlined)
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
