<script>
import EventBus from '@/shared/services/event_bus'
import I18n from '@/i18n'

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
      stopStreams: function() {}
    }
  },

  mounted() {
    navigator.mediaDevices.getUserMedia({
      audio: true,
      video: {
        facingMode: "user",
        width: 320,
        frameRate: 10,
      }
    }).then(this.setupRecorder, this.handleError)
  },

  methods: {
    handleError(e) {
      this.error = I18n.t("record_modal.no_camera")
    },

    mediaFilename() {
      if (MediaRecorder.isTypeSupported('video/webm')) {
        return "video.webm";
      } else if (MediaRecorder.isTypeSupported('video/mp4')) {
        return "video.mp4";
      }
    },

    mediaRecorderOptions() {
      if (MediaRecorder.isTypeSupported('video/webm;codecs=vp9,opus')) {
        return {mimeType: 'video/webm;codecs=vp9,opus'};
      } else if (MediaRecorder.isTypeSupported('video/mp4')) {
        return {mimeType: 'video/mp4'};
      }
    },

    blobMimetype() {
      if (MediaRecorder.isTypeSupported('video/webm')) {
        return 'video/webm';
      } else if (MediaRecorder.isTypeSupported('video/mp4')) {
        return 'video/mp4';
      }
    },

    setupRecorder(stream) {
      this.stopStreams = function() {
        stream.getTracks().forEach((track) => {
          if (track.readyState == 'live') {track.stop(); }
        });
      }

      this.$refs.video.muted = true;
      this.$refs.video.srcObject = stream;

      this.$refs.video.controls = false;
      mediaRecorder = new MediaRecorder(stream, this.mediaRecorderOptions());
      mediaRecorder.ondataavailable = function(e) {
        chunks.push(e.data);
      }

      mediaRecorder.onstop = (e) => {
        this.$refs.video.srcObject = null;
        this.$refs.video.controls = true;
        this.$refs.video.muted = false;
        blob = new Blob(chunks, { 'type' : this.blobMimetype() });
        chunks = [];
        const url = URL.createObjectURL(blob);
        this.url = url;
        this.$refs.video.src = url;
      }
    },

    dismiss() {
      this.stopStreams();
      EventBus.$emit('closeModal')
    },

    submit() {
      this.saveFn(new File([blob], this.mediaFilename(),  { lastModified: new Date().getTime(), type: blob.type }));
      this.stopStreams();
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
      h1.text-h5(v-t="'record_modal.record_video'")
      v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='dismiss')
        common-icon(name="mdi-close")
 
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
