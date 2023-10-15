<script>

function startRecording(stream) {
  let recorder = new MediaRecorder(stream);
  let data = [];

  recorder.ondataavailable = (event) => data.push(event.data);
  recorder.start();

  let stopped = new Promise((resolve, reject) => {
    recorder.onstop = resolve;
    recorder.onerror = (event) => reject(event.name);
  });

  return Promise.all([stopped]).then(() => data);
}

function stop(stream, setRecording) {
  stream.getTracks().forEach((track) => track.stop());
}

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

  methods: {
    submit() {
      this.saveFn(new File([this.blob], "video.webm",  { lastModified: new Date().getTime(), type: this.blob.type }));
    },

    stop() {
      stop(this.$refs.video.srcObject);
    },

    start() {
      navigator.mediaDevices
        .getUserMedia({
          video: true,
          audio: true,
        })
        .then((stream) => {
          this.onAir = true
          this.$refs.video.srcObject = stream;
          this.$refs.video.captureStream = this.$refs.video.captureStream || this.$refs.video.mozCaptureStream;
          return new Promise((resolve) => (this.$refs.video.onplaying = resolve));
        })
        .then(() => startRecording(this.$refs.video.captureStream()))
        .then((recordedChunks) => {
          this.onAir = false
          this.blob = new Blob(recordedChunks, { type: "video/webm" });
          this.$refs.video.srcObject = null
          this.$refs.video.src = URL.createObjectURL(this.blob);

          console.log(`Successfully recorded ${this.blob.size} bytes of ${this.blob.type} media.`);
        })
        .catch((error) => {
          console.log(error);
        });
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

    video(ref="video" width="640" height="360" autoplay muted controls)

    .d-flex
      v-spacer
      v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start") Record
      v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop") Stop
      v-spacer
      v-btn.poll-members-form__submit(color="primary" @click="submit") Submit
 
</template>