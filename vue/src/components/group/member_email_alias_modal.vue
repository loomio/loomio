<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import { debounce } from 'lodash-es';

export default {
  props: {
    email: String,
    group: Object,
    submit: Function
  },

  data() {
    return {
      q: null,
      users: [],
      selectedUser: null
    }
  },

  mounted() {
    this.fetch();
  },

  watch: {
    q: 'fetch'
  },
  methods: {
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
  .pa-4(v-if="!selectedUser")
    p.text--secondary(v-t="{path: 'email_to_group.who_is_the_owner_of_email', args:{email: email}}")
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
    p(v-t="{path: 'email_to_group.is_name_the_owner_of_email', args: {name: selectedUser.name, email: email}}")
    p(v-t="{path: 'email_to_group.all_email_will_belong_to_name', args: {name: selectedUser.name, email: email}}")
  v-card-actions(v-if="selectedUser")
    v-btn(@click="selectedUser = null" v-t="'common.action.cancel'")
    v-spacer
    v-btn(color="primary" @click="submit(selectedUser.id)" v-t="'common.action.confirm'")



</template>
