<script lang="coffee">
import Flash from '@/shared/services/flash'
import Records from '@/shared/services/records'

export default
  props:
    user: Object
  methods:
    submit: ->
      Records.remote.post 'memberships/user_name',
        id: @user.id
        name: @user.name
        username: @user.username
      .then =>
        Flash.success "user_name_modal.user_name_updated"
        @closeModal()

</script>
<template lang="pug">
v-card.user-name-modal
  submit-overlay(:value='user.processing')
  v-card-title
    h1.headline(tabindex="-1" v-t="'user_name_modal.set_user_name'")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(:label="$t('profile_page.email_label')" v-model="user.email" disabled)
    v-text-field(:label="$t('profile_page.name_label')" v-model="user.name")
    v-text-field(:label="$t('profile_page.username_label')" v-model="user.username")
  v-card-actions
    v-spacer
    v-btn.primary(@click="submit" v-t="'common.action.save'")
</template>
