<script setup>
import { onMounted, onUnmounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import { approximate } from '@/shared/helpers/format_time';

const { t } = useI18n();
const credentials = ref(null);
const name = ref(AuthService.suggestedPasskeyName());
const loading = ref(false);
const supported = AuthService.passkeysSupported();

const load = async () => {
  const data = await AuthService.passkeyCredentials();
  credentials.value = data.passkey_credentials || [];
};

// The browser can retain its profile after the server session expires. Clear
// credential metadata and request sign-in; only a fresh load restores controls.
const handleUnauthorized = (error) => {
  if (error.status !== 401) return false;
  credentials.value = null;
  EventBus.$emit('openAuthModal');
  return true;
};

const refresh = async () => {
  if (!supported) return;
  credentials.value = null;
  try {
    await load();
  } catch (error) {
    if (!handleUnauthorized(error)) throw error;
  }
};

const add = async () => {
  loading.value = true;
  try {
    await AuthService.createPasskey(name.value.trim());
    name.value = AuthService.suggestedPasskeyName();
    await load();
    Flash.success('passkey_settings.added');
  } catch (error) {
    if (handleUnauthorized(error)) return;
    if (error?.name !== 'NotAllowedError') {
      const message = error?.errors?.passkey?.[0];
      message ? Flash.error(message) : Flash.error('auth_form.passkey_registration_failed');
    }
  } finally {
    loading.value = false;
  }
};

const remove = async (credential) => {
  if (!window.confirm(t('passkey_settings.remove_confirm', { name: credential.name }))) return;

  loading.value = true;
  try {
    await AuthService.removePasskey(credential.id);
    await load();
    Flash.success('passkey_settings.removed');
  } catch (error) {
    if (handleUnauthorized(error)) return;
    const message = error?.errors?.passkey?.[0];
    message ? Flash.error(message) : Flash.error('passkey_settings.remove_failed');
  } finally {
    loading.value = false;
  }
};

onMounted(refresh);
EventBus.$on('signedIn', refresh);
onUnmounted(() => EventBus.$off('signedIn', refresh));
</script>

<template lang="pug">
v-card.passkey-settings.mt-4(v-if="supported && credentials !== null" :title="t('passkey_settings.title')")
  v-card-text
    p.text-medium-emphasis {{ t('passkey_settings.helptext') }}
    v-list(v-if="credentials.length" lines="two")
      v-list-item(v-for="credential in credentials" :key="credential.id")
        template(v-slot:prepend)
          common-icon(name="mdi-key-variant")
        v-list-item-title {{ credential.name }}
        v-list-item-subtitle {{ t('passkey_settings.created_at', { date: approximate(new Date(credential.created_at)) }) }}
        template(v-slot:append)
          v-btn.passkey-settings__remove(
            icon
            variant="text"
            :aria-label="t('passkey_settings.remove_named', { name: credential.name })"
            :disabled="loading"
            @click="remove(credential)")
            common-icon(name="mdi-delete-outline")
    p(v-else) {{ t('passkey_settings.none') }}
    v-text-field.passkey-settings__name.mt-4(
      v-model="name"
      :label="t('passkey_settings.name')"
      :placeholder="t('passkey_settings.name_placeholder')")
  v-card-actions
    v-spacer
    v-btn.passkey-settings__add(
      color="primary"
      variant="elevated"
      :loading="loading"
      @click="add") {{ t('passkey_settings.add') }}
</template>
