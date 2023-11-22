<script lang="js">
import Session        from '@/shared/services/session';
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

export default {
  data() {
    return {
      targetEmail: null,
      emailChecked: false,
      emailExists: false
    };
  },

  computed: {
    isCurrentEmail() {
      return Session.user().email === this.targetEmail;
    }
  },

  methods: {
    reset() {
      this.targetEmail = null;
      this.emailChecked = false;
      this.emailExists = false;
    },

    sendVerification() {
      Records.users.sendMergeVerificationEmail(this.targetEmail).then(() => {
        Flash.success('merge_accounts.modal.flash');
        EventBus.$emit('closeModal');
      });
    },

    checkEmailExistence() {
      if (this.isCurrentEmail) { return; }
      Records.users.checkEmailExistence(this.targetEmail).then(res => {
        this.emailChecked = true;
        this.emailExists = res.exists;
      });
    }
  }
};

</script>

<template>

<v-card>
  <v-card-title>
    <h1 class="headline">Merge accounts</h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <div v-if="!emailChecked">
      <p>Do you have another Loomio account you would like to merge this account with? Enter the corresponding email address and we'll check to see the other account exists.</p>
      <p>After that you'll need to verify that the email account is yours before we can proceed with the merge.</p>
      <v-text-field v-model="targetEmail" label="another@email.com"></v-text-field>
    </div>
    <div v-if="emailChecked && emailExists">
      <p>We've confirmed that the email address {{targetEmail}} belongs to another account.</p>
      <p>Would you like to proceed with verifying {{targetEmail}} belongs to you?</p>
    </div>
    <div v-if="emailChecked && !emailExists">
      <p>Unfortunately, we could not find a corresponding account for this email address. Please try again.</p>
    </div>
  </v-card-text>
  <v-card-actions>
    <v-btn v-if="emailChecked" color="accent" @click="reset">Try another email address</v-btn>
    <v-spacer></v-spacer>
    <v-btn v-if="!emailChecked && !emailExists" color="accent" @click="checkEmailExistence" :disabled="!targetEmail">Check address</v-btn>
    <v-btn v-if="emailChecked && emailExists" color="primary" @click="sendVerification">Verify address</v-btn>
  </v-card-actions>
</v-card>
</template>
