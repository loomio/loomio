<script lang="js">
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';

export default
{
  props: {
    user: Object
  },
  methods: {
    submit() {
      Records.remote.post('memberships/user_name', {
        id: this.user.id,
        name: this.user.name,
        username: this.user.username
      }).then(() => {
        Flash.success("user_name_modal.user_name_updated");
        this.closeModal();
      }).catch(data => {
        this.user.saveError(data);
      });
    }
  }
};

</script>
<template>

<v-card class="user-name-modal">
  <submit-overlay :value="user.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'membership_dropdown.set_name_and_username'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <v-text-field :label="$t('profile_page.email_label')" v-model="user.email" disabled="disabled"></v-text-field>
    <v-text-field :label="$t('profile_page.name_label')" v-model="user.name"></v-text-field>
    <validation-errors :subject="user" field="name"></validation-errors>
    <v-text-field :label="$t('profile_page.username_label')" v-model="user.username"></v-text-field>
    <validation-errors :subject="user" field="username"></validation-errors>
  </v-card-text>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn class="primary" @click="submit" v-t="'common.action.save'"></v-btn>
  </v-card-actions>
</v-card>
</template>
