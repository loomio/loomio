var waitFor = function(selector, fn, cancelled = () => false) {
  if (cancelled()) { return; }

  if (document.querySelector(selector)) {
    fn();
  } else {
    setTimeout(() => waitFor(selector, fn, cancelled) , 200);
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

  scrollToSettled(selector, offset, options = {}) {
    const scrollOffset = offset == null ? 72 : offset;
    const tolerance = options.tolerance || 2;
    const stableFrames = options.stableFrames || 3;
    const timeout = options.timeout || 1600;
    const minDuration = options.minDuration || 600;
    const waitTimeout = options.waitTimeout || timeout;
    let cancelled = false;
    let frameId = null;
    const waitStartedAt = performance.now();

    const cancel = () => {
      cancelled = true;
      if (frameId) { cancelAnimationFrame(frameId); }
    };

    waitFor(selector, () => {
      const startedAt = performance.now();
      let alignedFrames = 0;

      const tick = () => {
        if (cancelled) { return; }

        const target = document.querySelector(selector);
        if (!target) {
          alignedFrames = 0;
        } else if (Math.abs(target.getBoundingClientRect().top - scrollOffset) > tolerance) {
          this.elementScrollTo(window, selector, null, 'instant', scrollOffset, false);
          alignedFrames = 0;
        } else {
          alignedFrames += 1;
        }

        const elapsed = performance.now() - startedAt;
        if ((alignedFrames >= stableFrames && elapsed >= minDuration) || elapsed > timeout) {
          if (target) {
            target.classList.remove('scroll-highlight');
            void target.offsetWidth;
            target.classList.add('scroll-highlight');
          }
          return;
        }

        frameId = requestAnimationFrame(tick);
      };

      frameId = requestAnimationFrame(tick);
    }, () => cancelled || performance.now() - waitStartedAt > waitTimeout);

    return cancel;
  }

  elementScrollTo(el, selector, callback, behavior = 'instant', offset = 0, highlight = true) {
    waitFor(selector, () => {
      // console.log(`document.querySelector("${selector}").getBoundingClientRect().top -> `, document.querySelector(selector).getBoundingClientRect().top);
      // console.log(`document.body.getBoundingClientRect().top -> `, document.body.getBoundingClientRect().top);
      // console.log(`${document.querySelector(selector).getBoundingClientRect().top} - ${document.body.getBoundingClientRect().top} - ${offset}`);
      const target = document.querySelector(selector);
      el.scrollTo({
        behavior: behavior,
        top:
          target.getBoundingClientRect().top -
          document.body.getBoundingClientRect().top -
          offset,
      })

      if (highlight) {
        target.classList.remove('scroll-highlight');
        void target.offsetWidth;
        target.classList.add('scroll-highlight');
      }

      if (callback) { callback(); }
    });
  }
}
