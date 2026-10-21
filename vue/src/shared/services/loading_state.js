import { computed, ref } from 'vue';

const pendingReads = ref(0);
export const loading = computed(() => pendingReads.value > 0);

// Count requests through response import, so concurrent reads cannot hide the
// indicator while another response is still updating the client database.
export function trackRead(request) {
  pendingReads.value += 1;
  return request.finally(() => { pendingReads.value -= 1; });
}
