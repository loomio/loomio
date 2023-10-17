<script>
import EventBus from '@/shared/services/event_bus'

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
    }
  },

  mounted() {
    navigator.mediaDevices.getUserMedia({
      audio: true,
      video: {
        facingMode: "user",
        width: 640,
        frameRate: 15,
      }
    }).then(this.setupRecorder, this.handleError)
  },

  methods: {
    handleError(e) {
      console.log(e)
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
      h1.headline Make recording
      dismiss-modal-button

    video(ref="video" width="640" height="360" autoplay muted controls playsinline)

    .d-flex
      v-spacer
      v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start") Record
      v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop") Stop
      v-spacer
      v-btn.poll-members-form__submit(color="primary" @click="submit") Submit
 
</template>