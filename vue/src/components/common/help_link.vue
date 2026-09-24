<script setup lang="js">
import { useI18n } from 'vue-i18n';

defineProps({
  path: String
});

const { t } = useI18n();
</script>

<template lang="pug">
a.help-link.text-decoration-underline(
  style="color: inherit"
  :href="'/docs/en/'+path"
  target="_blank"
  rel="noopener noreferrer"
)
  span {{ t('common.read_more') }}
  common-icon.ml-1(size="small" name="mdi-open-in-new")
</template>
