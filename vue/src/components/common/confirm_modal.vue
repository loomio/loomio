<script lang="js">
import Flash  from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { I18n } from '@/i18n';

export default {
  props: {
    close: {
      type: Function,
      default() {
        EventBus.$emit('closeModal');
      }
    },
    confirm: Object
  },

  data() {
    return {
      isDisabled: false,
      confirmText: ''
    };
  },

  methods: {
    submit() {
      this.isDisabled = true;
      this.confirm.submit().then(() => {
        this.close();
        if (this.confirm.redirect != null) { this.$router.push(`${this.confirm.redirect}`); }
        if (typeof this.confirm.successCallback === 'function') { this.confirm.successCallback(); }
        if (this.confirm.text.flash) { Flash.success(this.confirm.text.flash, this.confirm.textArgs); }
      }).finally(() => {
        this.isDisabled = false;
      });
    }
  },

  computed: {
    title() {
      return this.confirm.text.raw_title || I18n.global.t(this.confirm.text.title, this.confirm.textArgs)
    },
    canProceed() {
      if (this.confirm.text.confirm_text) {
        return this.confirmText.trim()  === this.confirm.text.confirm_text.trim();
      } else {
        return true;
      }
    }
  }
}
</script>

<template lang="pug">
v-card.confirm-modal(:title)
  template(v-slot:append)
    dismiss-modal-button(v-if="!confirm.forceSubmit")
  v-card-text.lmo-markdown-wrapper
    div(
      v-if="confirm.text.raw_helptext || confirm.text.helptext"
      v-html="confirm.text.raw_helptext || $t(confirm.text.helptext, confirm.textArgs)")
    div(v-if="confirm.text.confirm_text")
      p.font-weight-bold {{confirm.text.raw_confirm_text_placeholder}}
      v-text-field.confirm-text-field(v-model="confirmText" v-on:keyup.enter="canProceed && submit()")

  v-card-actions
    v-btn(text v-if="!confirm.forceSubmit" @click="close()")
      span(v-t="confirm.text.cancel || 'common.action.cancel'")
    v-spacer
    v-btn.confirm-modal__submit(
      variant="elevated"
      :disabled="!canProceed"
      color="primary"
      @click="(confirm.submit && submit()) || close()"
    )
      span(v-t="{path: (confirm.text.submit || 'common.action.ok'), args: confirm.textArgs}")
</template>
