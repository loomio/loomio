const SAFE_SCHEME = /^(https?:|mailto:|tel:|ftp:|\/|#|\.|[^:]*$)/i;

export function safeUrl(url) {
  // Strip whitespace and controls before checking for obfuscated schemes.
  const trimmed = String(url == null ? '' : url).replace(/[\u0000-\u0020]+/g, '');
  return SAFE_SCHEME.test(trimmed) ? url : '#';
}
