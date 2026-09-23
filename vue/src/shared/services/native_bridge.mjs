const VERSION = 1;
const HANDLER_NAME = 'loomioNative';

export function createNativeBridge(browserWindow = globalThis.window) {
  const handler = browserWindow?.webkit?.messageHandlers?.[HANDLER_NAME];

  return {
    available() {
      return typeof handler?.postMessage === 'function';
    },

    async invoke(action) {
      if (!this.available()) throw new Error('native_bridge_unavailable');
      const response = await handler.postMessage({ version: VERSION, action });
      if (response?.version !== VERSION || response?.platform !== 'ios') {
        throw new Error('native_bridge_invalid_response');
      }
      return response;
    }
  };
}

export default createNativeBridge();
