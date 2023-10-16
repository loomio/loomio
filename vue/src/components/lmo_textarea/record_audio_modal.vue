<script>
import EventBus from '@/shared/services/event_bus'

let audioCtx;

function visualize(stream) {
  if(!audioCtx) {
    audioCtx = new AudioContext();
  }

  const source = audioCtx.createMediaStreamSource(stream);

  const analyser = audioCtx.createAnalyser();
  analyser.fftSize = 2048;
  const bufferLength = analyser.frequencyBinCount;
  const dataArray = new Uint8Array(bufferLength);

  source.connect(analyser);
  //analyser.connect(audioCtx.destination);

  const canvas = document.querySelector('.visualizer');
  const canvasCtx = canvas.getContext("2d");

  draw()

  function draw() {
    const WIDTH = canvas.width
    const HEIGHT = canvas.height;

    requestAnimationFrame(draw);

    analyser.getByteTimeDomainData(dataArray);

    canvasCtx.fillStyle = 'rgb(200, 200, 200)';
    canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);

    canvasCtx.lineWidth = 2;
    canvasCtx.strokeStyle = 'rgb(0, 0, 0)';

    canvasCtx.beginPath();

    let sliceWidth = WIDTH * 1.0 / bufferLength;
    let x = 0;


    for(let i = 0; i < bufferLength; i++) {

      let v = dataArray[i] / 128.0;
      let y = v * HEIGHT/2;

      if(i === 0) {
        canvasCtx.moveTo(x, y);
      } else {
        canvasCtx.lineTo(x, y);
      }

      x += sliceWidth;
    }

    canvasCtx.lineTo(canvas.width, canvas.height/2);
    canvasCtx.stroke();

  }
}

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
      this.saveFn(new File([this.blob], "audio.webm",  { lastModified: new Date().getTime(), type: this.blob.type }));
      EventBus.$emit('closeModal')
    },

    stopVideo() {
      stop(this.$refs.audio.srcObject);
    },
    
    stop() {
      stop(this.$refs.audio.srcObject);
    },

    start() {
      navigator.mediaDevices
        .getUserMedia({audio: true})
        .then((stream) => {
          this.onAir = true
          visualize(stream);
          this.$refs.audio.muted = true;
          this.$refs.audio.srcObject = stream;
          this.$refs.audio.captureStream = this.$refs.audio.captureStream || this.$refs.audio.mozCaptureStream;
          return new Promise((resolve) => (this.$refs.audio.onplaying = resolve));
        })
        .then(() => startRecording(this.$refs.audio.captureStream()))
        .then((recordedChunks) => {
          this.onAir = false
          // this.blob = new Blob(recordedChunks, {type: "audio/opus" });
          this.blob = new Blob(recordedChunks, {type: "audio/webm;codecs=opus" });
          this.$refs.audio.srcObject = null
          this.$refs.audio.src = URL.createObjectURL(this.blob);
          this.$refs.audio.muted = false

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

    canvas(class="visualizer" height="60px")
    audio(ref="audio" autoplay controls playsinline)

    .d-flex
      v-spacer
      v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start") Record
      v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop") Stop
      v-spacer
      v-btn.poll-members-form__submit(color="primary" @click="submit") Submit
 
</template>