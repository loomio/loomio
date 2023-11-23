<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';

export default {
  props: {
    email: String,
    group: Object,
    submit: Function
  },

  data() {
    return {
      q: null,
      users: []
    }
  },

  mounted() {
    this.fetch();
  },

  methods: {
    fetch() {
      Records.memberships.fetch({
        params: {
          q: this.q,
          group_id: this.group.id,
          exclude_types: 'group'
        }
      }).then((data) => {
        this.users = Records.users.find(data.users.map(u => u.id))
      });
    }
  }
};

</script>
<template lang="pug">
v-card
  v-card-title
    h1.headline Add alias for {{email}}
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(
      v-model="q"
      autofocus
      filled
      rounded
      single-line
      hide-details
      :placeholder="$t('common.action.search')"
      @keydown.enter.prevent="fetch"
      @change="fetch"
    )
    v-list(v-for="user in users")
      v-list-item(@click="submit(user.id)") {{user.name}}

</template>
