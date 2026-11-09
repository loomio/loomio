import { shallowReactive } from 'vue';

// Shallow so computed queries track config keys such as currentUserId, while
// stored objects (AppConfig.records and boot data) are returned unwrapped.
window.Loomio = shallowReactive({});
export default window.Loomio;
