/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
export var hardReload = function(path) {
  if (path) {
    return window.location.href = path;
  } else {
    return window.location.reload();
  }
};

export var print = () => window.print();
export var is2x = () => window.devicePixelRatio >= 2;
