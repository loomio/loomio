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
<template lang="pug">
v-card.user-name-modal
  submit-overlay(:value='user.processing')
  v-card-title
    h1.headline(tabindex="-1" v-t="'membership_dropdown.set_name_and_username'")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(:label="$t('profile_page.email_label')" v-model="user.email" disabled)
    v-text-field(:label="$t('profile_page.name_label')" v-model="user.name")
    validation-errors(:subject='user' field='name')
    v-text-field(:label="$t('profile_page.username_label')" v-model="user.username")
    validation-errors(:subject='user', field='username')
  v-card-actions
    v-spacer
    v-btn.primary(@click="submit" v-t="'common.action.save'")
</template>
