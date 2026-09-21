<script setup>
import { onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import Flash from '@/shared/services/flash';
import { approximate } from '@/shared/helpers/format_time';

const { t } = useI18n();
const credentials = ref([]);
const name = ref('');
const loading = ref(false);
const supported = AuthService.passkeysSupported();

const load = async () => {
  const data = await AuthService.passkeyCredentials();
  credentials.value = data.passkey_credentials || [];
};

const add = async () => {
  if (!name.value.trim()) return;
  loading.value = true;
  try {
    await AuthService.createPasskey(name.value.trim());
    name.value = '';
    await load();
    Flash.success('passkey_settings.added');
  } catch (error) {
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
    const message = error?.errors?.passkey?.[0];
    message ? Flash.error(message) : Flash.error('passkey_settings.remove_failed');
  } finally {
    loading.value = false;
  }
};

onMounted(load);
</script>

<template lang="pug">
v-card.passkey-settings.mt-4(v-if="supported" :title="t('passkey_settings.title')")
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
            icon="mdi-delete-outline"
            variant="text"
            :aria-label="t('passkey_settings.remove_named', { name: credential.name })"
            :disabled="loading"
            @click="remove(credential)")
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
      :disabled="!name.trim()"
      :loading="loading"
      @click="add") {{ t('passkey_settings.add') }}
</template>
