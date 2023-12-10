<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { debounce } from 'lodash-es';

export default {
  props: {
    receivedEmail: Object,
    group: Object,
    callbackFn: Function
  },

  data() {
    return {
      q: null,
      users: [],
      selectedUser: null,
      loading: false
    }
  },

  mounted() {
    this.fetch();
  },

  watch: {
    q: 'fetch'
  },
  methods: {
    submit(userId) {
      this.loading = true;
      Records.receivedEmails.remote.postMember(this.receivedEmail.id, 'allow', {user_id: userId}).then(() => {
        EventBus.$emit('closeModal');
        Flash.success('email_to_group.email_released');
        this.callbackFn();
      }).finally(() => {
        this.loading = false;
      });
    },

    fetch: debounce(function() {
      Records.memberships.fetch({
        params: {
          q: this.q,
          group_id: this.group.id,
          exclude_types: 'group'
        }
      }).then((data) => {
        this.users = Records.users.find(data.users.map(u => u.id))
      });
    }, 250)
  }
};

</script>
<template lang="pug">
v-card
  v-card-title
    h1.headline(v-t="'email_to_group.add_alias'")
    v-spacer
    dismiss-modal-button
  template(v-if="group.isTrialOrDemo()")
    .pa-4
      p(v-t="'email_to_group.not_available_to_trial_or_demo'")
  template(v-else)
    .pa-4(v-if="!selectedUser")
      p.text--secondary(v-t="{path: 'email_to_group.who_is_the_owner_of_email', args:{email: receivedEmail.senderEmail}}")
      v-text-field(
        v-model="q"
        autofocus
        filled
        rounded
        single-line
        hide-details
        :placeholder="$t('common.action.search')"
      )
      v-list(v-for="user in users")
        v-list-item(@click="selectedUser = user") {{user.name}}

    .pa-4.text--secondary(v-if="selectedUser")
      p(v-t="{path: 'email_to_group.is_name_the_owner_of_email', args: {name: selectedUser.name, email: receivedEmail.senderEmail}}")
      p(v-t="{path: 'email_to_group.all_email_will_belong_to_name', args: {name: selectedUser.name, email: receivedEmail.senderEmail}}")
    v-card-actions(v-if="selectedUser")
      v-btn(@click="selectedUser = null" v-t="'common.action.cancel'")
      v-spacer
      v-btn(color="primary" @click="submit(selectedUser.id)" :loading="loading" v-t="'common.action.confirm'")



</template>
