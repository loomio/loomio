<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash    from '@/shared/services/flash';
import md5      from "md5";

const fileInput = ref(null);

const user                    = ref(Session.user().clone());
const uploading               = ref(false);
const progress                = ref(0);
const previous_uploaded_avatar = ref(undefined);

const gravatarUrl = computed(() => {
  const hash = md5(user.value.email.trim().toLowerCase());
  return `https://www.gravatar.com/avatar/${hash}?s=256`;
});

function selectFile() {
  fileInput.value.click();
}

function uploadFile() {
  uploading.value = true;
  Records.users.remote.onUploadSuccess = response => {
    Records.importJSON(response);
    EventBus.$emit('updateProfile');
    EventBus.$emit('closeModal');
    uploading.value = false;
  };
  Records.users.remote.upload('upload_avatar', fileInput.value.files[0], {}, args => { progress.value = (args.loaded / args.total) * 100; });
}

function submit(kind) {
  user.value.avatarKind = kind;
  Records.users.updateProfile(user.value).then(() => {
    Flash.success('profile_page.messages.picture_changed');
    EventBus.$emit('updateProfile');
    EventBus.$emit('closeModal');
  }).catch(() => true);
}

onMounted(() => {
  Records.users.saveExperience("changePicture");
  Records.users.fetch({path: 'avatar_uploaded'}).then(res => {
    previous_uploaded_avatar.value = res.avatar_uploaded;
  });
});
</script>

<template lang="pug">
v-card.change-picture-form(:title="$t('change_picture_form.title')")
  template(v-slot:append)
    dismiss-modal-button
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  v-card-text
    p.text-medium-emphasis(v-html="$t('change_picture_form.helptext')")
    v-list.change-picture-form__options-list
      v-list-item.change-picture-form__option(@click='selectFile()')
        template(v-slot:prepend)
          v-avatar
            common-icon(name="mdi-camera")
        v-list-item-title(v-t="'change_picture_form.use_uploaded'")
          input.hidden.change-picture-form__file-input(type="file" ref="fileInput" @change='uploadFile' accept="image/png, image/jpeg, image/webp")
      v-list-item.change-picture-form__option(v-if="previous_uploaded_avatar" @click="submit('uploaded')")
        template(v-slot:prepend)
          v-avatar
            v-img(cover :src="previous_uploaded_avatar")
        v-list-item-title(v-t="'change_picture_form.existing_upload'")
      v-list-item.change-picture-form__option(@click="submit('gravatar')")
        template(v-slot:prepend)
          v-avatar
            v-img(:src="gravatarUrl")
        v-list-item-title(v-t="'change_picture_form.use_gravatar'")
      v-list-item.change-picture-form__option(@click="submit('initials')")
        template(v-slot:prepend).user-avatar
          v-avatar.user-avatar__initials--small {{user.avatarInitials}}
        v-list-item-title(v-t="'change_picture_form.use_initials'")
</template>
