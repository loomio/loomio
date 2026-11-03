// The rich text editor inside `scope` (a page or locator), once its saved
// content has loaded. Text typed before then would be overwritten.
export function editor(scope) {
  return scope.locator('.collab-editor--synced .ProseMirror');
}
