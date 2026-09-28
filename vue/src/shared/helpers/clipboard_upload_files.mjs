export function clipboardUploadFiles(clipboardData) {
  const files = Array.from(clipboardData.items).map(item => item.getAsFile()).filter(Boolean);
  if (files.length === 0) { return []; }

  const filename = clipboardData.getData('text/plain').trim() || String(Date.now());
  return files.map(file => new File([file], filename, { lastModified: Date.now(), type: file.type }));
}
