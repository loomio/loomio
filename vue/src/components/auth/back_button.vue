<script setup>
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
</script>

<template lang="pug">
v-btn.auth-back-button(
  type="button"
  icon
  variant="text"
  :title="t('common.action.back')"
  :aria-label="t('common.action.back')")
  common-icon(name="mdi-close")
</template>
