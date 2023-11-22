<script lang="js">
import Flash from '@/shared/services/flash';

export default
{
  props: {
    membership: Object
  },
  data() {
    return {isDisabled: false};
  },
  methods: {
    submit() {
      this.membership.save().then(() => {
        Flash.success("membership_form.updated");
        this.closeModal();
      });
    }
  }
}

</script>
<template>

<v-card class="membership-modal">
  <submit-overlay :value="membership.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'membership_form.modal_title.group'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text class="membership-form">
    <p class="text--secondary membership-form__helptext" v-t="{ path: 'membership_form.title_helptext.group', args: { name: membership.user().name } }"></p>
    <label for="membership-title" v-t="'membership_form.title_label'"></label>
    <v-text-field class="membership-form__title-input lmo-primary-form-input" id="membership-title" autofocus="autofocus" v-on:keyup.enter="submit" :placeholder="$t('membership_form.title_placeholder')" v-model="membership.title" maxlength="255"></v-text-field>
    <validation-errors :subject="membership" field="title"></validation-errors>
  </v-card-text>
  <v-card-actions class="membership-form-actions">
    <v-spacer></v-spacer>
    <v-btn class="membership-form__submit" color="primary" @click="submit()" v-t="'common.action.save'"></v-btn>
  </v-card-actions>
</v-card>
</template>
