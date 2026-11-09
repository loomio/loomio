const callbacks = new Map();
let observer;

// Share one observer across thread bodies and stop observing revealed content.
export function observeResize(element, callback) {
  observer ||= new ResizeObserver(entries => {
    entries.forEach(entry => callbacks.get(entry.target)?.());
  });
  callbacks.set(element, callback);
  observer.observe(element);
  return () => {
    if (!callbacks.delete(element)) return;
    observer.unobserve(element);
    if (callbacks.size === 0) {
      observer.disconnect();
      observer = null;
    }
  };
}
