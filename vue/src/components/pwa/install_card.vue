<script setup lang="js">
import { computed } from 'vue';
import AppConfig from '@/shared/services/app_config';
import PwaService from '@/shared/services/pwa_service';

const siteName = computed(() => AppConfig.theme.site_name);
const show = computed(() => PwaService.state.nativeInstallAvailable || PwaService.state.iosInstallAvailable);

function install() {
  PwaService.promptInstall().catch(() => {});
}
</script>

<template lang="pug">
v-card.pwa-install-card.mb-4(
  v-if="show"
  :title="$t('install_app.install_title', { site_name: siteName })")
  v-card-text
    p.text-medium-emphasis(v-if="PwaService.state.iosInstallAvailable") {{ $t('install_app.ios_install_description', { site_name: siteName }) }}
    p.text-medium-emphasis(v-else) {{ $t('install_app.install_description', { site_name: siteName }) }}
  v-card-actions(v-if="PwaService.state.nativeInstallAvailable")
    v-spacer
    v-btn(
      color="primary"
      variant="tonal"
      @click="install")
      template(v-slot:prepend)
        common-icon(name="mdi-download")
      span {{ $t('install_app.install_button') }}
</template>
