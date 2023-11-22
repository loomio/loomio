<script lang="js">
import EventBus from '@/shared/services/event_bus';

export default {
  data() {
    return {
      flash: {},
      isOpen: false,
      message: '',
      seconds: 0,
      timer: null
    };
  },
  created() {
    EventBus.$on('flashMessage', flash => {
      this.flash = flash;
      this.isOpen = true;
      this.timer = window.setInterval(() => { this.seconds += 3; } , 1000);
    });
  },
  destroyed() {
    clearInterval(timer);
  }
};

</script>

<template>

<v-snackbar class="flash-root" top="top" v-model="isOpen" :color="flash.level == 'success' ? 'primary' : flash.level" :timeout="flash.duration"><span class="flash-root__message" v-if="flash.message" role="status" aria-live="assertive" v-t="{path: flash.message, args: flash.options}"></span><span class="flash-root__message" v-if="flash.text" role="status" aria-live="assertive"></span>
  <v-progress-linear class="mt-2" v-if="flash.level == 'wait'" :value="seconds"></v-progress-linear>
  <div class="flash-root__action" v-if="flash.actionFn"><a @click="flash.actionFn()" v-t="flash.action"></a></div>
</v-snackbar>
</template>
