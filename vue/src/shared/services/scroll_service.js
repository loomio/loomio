var waitFor = function(selector, fn) {
  if (document.querySelector(selector)) {
    fn();
  } else {
    setTimeout(() => waitFor(selector, fn) , 200);
  }
};

export default new class ScrollService {
  jumpTo(selector, offset = 0) {
    this.elementScrollTo(window, selector, null, 'instant', offset);
  }

  scrollTo(selector, offset) {
    if (offset == null) {
      this.elementScrollTo(window, selector, null, 'smooth', 72);
    } else {
      this.elementScrollTo(window, selector, null, 'instant', offset);
    }
  }

  elementScrollTo(el, selector, callback, behavior = 'instant', offset = 0) {
    waitFor(selector, () => {
      // console.log(`document.querySelector("${selector}").getBoundingClientRect().top -> `, document.querySelector(selector).getBoundingClientRect().top);
      // console.log(`document.body.getBoundingClientRect().top -> `, document.body.getBoundingClientRect().top);
      // console.log(`${document.querySelector(selector).getBoundingClientRect().top} - ${document.body.getBoundingClientRect().top} - ${offset}`);
      el.scrollTo({
        behavior: behavior,
        top:
          document.querySelector(selector).getBoundingClientRect().top -
          document.body.getBoundingClientRect().top -
          offset,
      })

      if (callback) { callback(); }
    });
  }
}
