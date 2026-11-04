// The rich text editor inside `scope` (a page or locator). Its document is
// seeded before it renders, so it is ready to type in straight away.
export function editor(scope) {
  return scope.locator('.collab-editor .ProseMirror');
}
