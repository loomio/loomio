<script>
import EventBus from '@/shared/services/event_bus'

let mediaRecorder;
let chunks = [];
let blob;

export default {
  props: {
    saveFn: Function
  },

  mounted() {
    navigator.mediaDevices.getUserMedia({audio: true}).then(this.setupRecorder, this.handleError)
  },

  unmounted() {
    // close the mediaDevice
  },

  data() {
    return {
      onAir: false,
    }
  },

  methods: {
    handleError(e) {
      console.log(e)
    },
    submit() {
      this.saveFn(new File([blob], "audio.webm",  { lastModified: new Date().getTime(), type: blob.type }));
      EventBus.$emit('closeModal')
    },

    setupRecorder(stream) {

      mediaRecorder = new MediaRecorder(stream);
      mediaRecorder.ondataavailable = function(e) {
        chunks.push(e.data);
      }

      mediaRecorder.onstop = (e) => {
        this.$refs.audio.setAttribute('controls', '');
        this.$refs.audio.controls = true;
        // blob = new Blob(chunks, { 'type' : 'audio/webm;codecs=vp8,opus' });
        blob = new Blob(chunks, { 'type' : 'audio/webm' });
        chunks = [];
        const audioURL = window.URL.createObjectURL(blob);
        this.$refs.audio.src = audioURL;
      }
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

    .d-flex.flex-column.align-center.pb-8
      audio(ref="audio" autoplay controls playsinline)

    .d-flex
      v-spacer
      v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start") Record
      v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop") Stop
      v-spacer
      v-btn.poll-members-form__submit(color="primary" @click="submit") Submit
 
</template>