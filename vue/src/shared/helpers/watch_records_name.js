let sequence = 0;

// Every mounted watcher owns its RecordView callback and cleanup. Include a
// process-local sequence even when callers provide a descriptive key so two
// live component instances can never reuse each other's view.
export function nextWatchRecordsName(collections, key) {
  sequence += 1;
  return [...collections, key, sequence].filter(value => value != null).join('_');
}
