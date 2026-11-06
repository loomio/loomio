const element = document.getElementById('initial-data');
const initialData = element ? JSON.parse(element.textContent) : {};
element?.remove();

export const bootData = initialData.boot;

export function clearInitialData() {
  delete initialData.requests;
}

export function clearInitialDataAfterNavigation(_to, from) {
  if (from.matched.length) clearInitialData();
}

// Match the complete request and consume it once. Route or session changes
// discard unused responses so later visits always refresh through the API.
export function takeInitialResponse(path, params) {
  const requests = initialData.requests || [];
  const keys = Object.keys(params);
  const index = requests.findIndex(request => request.path === path &&
    keys.length === Object.keys(request.params).length &&
    keys.every(key => String(params[key]) === String(request.params[key])));
  if (index < 0) return;
  return requests.splice(index, 1)[0].records;
}
