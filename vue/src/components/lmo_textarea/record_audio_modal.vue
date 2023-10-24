<script>
import AppConfig from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import I18n from '@/i18n.coffee'
let mediaRecorder;
let chunks = [];
let blob;
let canvas;
let canvasCtx;
let audioCtx

function visualize(stream, fillColor) {
  if(!audioCtx) {
    audioCtx = new AudioContext();
  }

  const source = audioCtx.createMediaStreamSource(stream);

  const analyser = audioCtx.createAnalyser();
  analyser.fftSize = 2048;
  const bufferLength = analyser.frequencyBinCount;
  const dataArray = new Uint8Array(bufferLength);

  source.connect(analyser);

  draw(fillColor)

  function draw(fillColor) {
    const WIDTH = canvas.width
    const HEIGHT = canvas.height;

    requestAnimationFrame(draw);

    analyser.getByteTimeDomainData(dataArray);

    canvasCtx.fillStyle = fillColor;
    canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);

    canvasCtx.lineWidth = 2;
    canvasCtx.strokeStyle = '#dca034';

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

export default {
  props: {
    saveFn: Function
  },

  data() {
    return {
      onAir: false,
      error: null,
      url: null,
      stopStreams: function() {},
      transcriptionAvailable: AppConfig.features.app.transcription, 
    }
  },

  mounted() {
    // if (/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
    //   this.error = "Sorry recording is not supported on Safari or iOS";
    // } else {
    canvas = this.$refs.visualizer
    canvasCtx = canvas.getContext("2d");
    navigator.mediaDevices.getUserMedia({audio: true}).then(this.setupRecorder, this.handleError)
    // }
  },

  methods: {
    handleError(e) {
      this.error = I18n.t("record_modal.no_mic")
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

    mediaFilename() {
      if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        return "audio.webm";
      } else if (MediaRecorder.isTypeSupported('audio/mp4')) {
        return "audio.mp4";
      }
    },

    mediaRecorderOptions() {
      if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        return {mimeType: 'audio/webm;codecs=opus'};
      } else if (MediaRecorder.isTypeSupported('audio/mp4')) {
        return {mimeType: "audio/mp4;codecs=mp4a"};
      }
    },

    blobMimetype() {
      if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        return 'audio/webm';
      } else if (MediaRecorder.isTypeSupported('audio/mp4')) {
        return 'audio/mp4';
      }
    },

    setupRecorder(stream) {
      this.stopStreams = function() {
        stream.getTracks().forEach((track) => {
          if (track.readyState == 'live') {track.stop(); }
        });
      }
      mediaRecorder = new MediaRecorder(stream, this.mediaRecorderOptions());
      visualize(stream, this.$vuetify.theme.dark ? "#1e1e1e" : "#ffffff")
      this.$refs.audio.controls = false;
      mediaRecorder.ondataavailable = function(e) {
        chunks.push(e.data);
      }

      mediaRecorder.onstop = (e) => {
        this.$refs.audio.controls = true;
        blob = new Blob(chunks, { 'type' : this.blobMimetype() });
        chunks = [];
        const audioURL = window.URL.createObjectURL(blob);
        this.$refs.audio.src = audioURL;
        this.url = audioURL;
      }
    },

    stop() {
      mediaRecorder.stop();
      this.onAir = false
    },

    start() {
      mediaRecorder.start(1000);
      this.onAir = true
    }
  },
}
</script>

<template lang="pug">
.recording-modal
  .pa-4
    .d-flex.justify-space-between
      h1.headline(v-t="'record_modal.record_audio'")
      v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='dismiss')
        v-icon mdi-close
    v-alert(v-if="error" type="error") {{error}}
    div(v-else)
      v-alert(type="info" v-if="!url && !onAir" icon="mdi-microphone")
        span(v-t="'record_modal.why_type_when_you_can_talk'")
        template(v-if="transcriptionAvailable")
          br
          span(v-t="'record_modal.transcript_included'")
      .d-flex.flex-column.align-center.pb-8
        canvas(v-show="onAir" ref="visualizer" height="64" width="256")
        audio(v-show="!onAir" ref="audio" autoplay controls playsinline)
      .d-flex
        v-spacer
        v-btn.poll-members-form__submit(v-if="!onAir" color="primary" @click="start" v-t="'record_modal.record'")
        v-btn.poll-members-form__submit(v-if="onAir" color="primary" @click="stop" v-t="'record_modal.stop'")
        v-spacer
        v-btn.poll-members-form__submit(v-if="!onAir && url" color="primary" @click="submit" v-t="'common.action.save'") 
</template>
