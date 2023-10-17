<script>
import EventBus from '@/shared/services/event_bus'
import I18n from '@/i18n.coffee'

let mediaRecorder;
let chunks = [];
let blob;

export default {
  props: {
    saveFn: Function
  },

  data() {
    return {
      onAir: false,
      blob: null,
      error: null,
      url: null,
    }
  },

  mounted() {
      if (/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
      this.error = "Sorry recording is not supported on Safari or iOS";
    } else {
      navigator.mediaDevices.getUserMedia({
        audio: true,
        video: {
          facingMode: "user",
          width: 640,
          frameRate: 15,
        }
      }).then(this.setupRecorder, this.handleError)
    }
  },

  methods: {
    handleError(e) {
      this.error = I18n.t("record_modal.no_camera")
    },
    setupRecorder(stream) {

      this.$refs.video.muted = true;
      this.$refs.video.srcObject = stream;

      this.$refs.video.controls = false;
      mediaRecorder = new MediaRecorder(stream);
      mediaRecorder.ondataavailable = function(e) {
        chunks.push(e.data);
      }

      mediaRecorder.onstop = (e) => {
        this.$refs.video.srcObject = null;
        this.$refs.video.controls = true;
        this.$refs.video.muted = false;
        blob = new Blob(chunks, { 'type' : 'video/webm' });
        chunks = [];
        const url = URL.createObjectURL(blob);
        this.url = url;
        this.$refs.video.src = url;
      }
    },
    submit() {
      this.saveFn(new File([blob], "video.webm",  { lastModified: new Date().getTime(), type: blob.type }));
      EventBus.$emit('closeModal')
    },

    stop() {
      mediaRecorder.stop();
      this.onAir = false
    },

    start() {
      mediaRecorder.start();
      this.onAir = true
    }
  },
}
</script>

<template lang="pug">
.recording-modal
  .pa-4
    .d-flex.justify-space-between
      h1.headline(v-t="'record_modal.record_video'")
      dismiss-modal-button

    v-alert(v-if="error" type="error") {{error}}
    div(v-else)
      video(ref="video" width="640" height="360" autoplay muted playsinline)

      .d-flex
        v-spacer
        v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start" v-t="'record_modal.record'")
        v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop" v-t="'record_modal.stop'")
        v-spacer
        v-btn.poll-members-form__submit(v-if="!onAir && url" color="primary" @click="submit" v-t="'common.action.save'")
 
</template>