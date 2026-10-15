const sidebarToggle = document.querySelector(".sidebar-toggle");
// Translated pages put their interface text on the root element.
const strings = {
  openNavigation: "Open navigation",
  closeNavigation: "Close navigation",
  copy: "Copy",
  copyLabel: "Copy code to clipboard",
  copied: "Copied",
  copyFailed: "Copy failed",
  ...document.documentElement.dataset
};
const sidebarScrim = document.querySelector(".sidebar-scrim");

// English stays in the built HTML. Translated images can be filled later in
// the existing client asset volume, without rebuilding or redeploying docs.
document.querySelectorAll("img[data-screenshot-sources]").forEach((image) => {
  const sources = [...new Set(JSON.parse(image.dataset.screenshotSources)
    .map(source => new URL(source, window.location.href).href))];
  let index = 0;
  function loadNext() {
    if (index === sources.length) {
      image.removeEventListener("error", loadNext);
      return;
    }
    const source = sources[index++];
    // Changing src alone leaves the browser using the previous 2x srcset.
    image.srcset = `${source} 2x`;
    image.src = source;
  }
  image.addEventListener("error", loadNext);
  loadNext();
});

function setNavigationOpen(open) {
  document.body.classList.toggle("navigation-open", open);
  sidebarToggle?.setAttribute("aria-expanded", String(open));
  sidebarToggle?.setAttribute("aria-label", open ? strings.closeNavigation : strings.openNavigation);
}

sidebarToggle?.addEventListener("click", () => {
  setNavigationOpen(!document.body.classList.contains("navigation-open"));
});

sidebarScrim?.addEventListener("click", () => setNavigationOpen(false));

document.querySelector("[data-language-select]")?.addEventListener("change", (event) => {
  window.location.href = event.target.value;
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") setNavigationOpen(false);
});

const tocLinks = Array.from(document.querySelectorAll(".page-toc a"));
if (tocLinks.length) {
  const toc = document.querySelector(".page-toc");
  const headings = tocLinks.map(link => document.getElementById(decodeURIComponent(link.hash.slice(1))));
  let currentLink;
  let framePending = false;

  // Follow the section at the top of the article. Keep its link visible by
  // scrolling only the TOC, so highlighting never moves the article itself.
  function updateCurrentSection() {
    framePending = false;
    let index = 0;
    for (let i = 0; i < headings.length; i++) {
      // Allow fractional anchor rounding without selecting a nearby child heading.
      if (headings[i].getBoundingClientRect().top > 2) break;
      index = i;
    }
    if (window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 1) {
      index = tocLinks.length - 1;
    }

    const link = tocLinks[index];
    if (link === currentLink) return;

    currentLink?.removeAttribute("aria-current");
    link.setAttribute("aria-current", "location");
    currentLink = link;

    const bounds = link.getBoundingClientRect();
    const viewport = toc.getBoundingClientRect();
    if (bounds.top < viewport.top) toc.scrollTop += bounds.top - viewport.top - 12;
    else if (bounds.bottom > viewport.bottom) toc.scrollTop += bounds.bottom - viewport.bottom + 12;
  }

  function scheduleCurrentSection() {
    if (framePending) return;
    framePending = true;
    window.requestAnimationFrame(updateCurrentSection);
  }

  window.addEventListener("scroll", scheduleCurrentSection, { passive: true });
  window.addEventListener("resize", scheduleCurrentSection);
  window.addEventListener("load", scheduleCurrentSection);
  updateCurrentSection();
}

function copyText(text) {
  if (navigator.clipboard?.writeText) return navigator.clipboard.writeText(text);

  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.append(textarea);
  textarea.select();
  document.execCommand("copy");
  textarea.remove();
  return Promise.resolve();
}

document.querySelectorAll("pre > code").forEach((code) => {
  const pre = code.parentElement;
  const wrapper = document.createElement("div");
  const button = document.createElement("button");

  wrapper.className = "code-block";
  button.className = "code-copy-button";
  button.type = "button";
  button.textContent = strings.copy;
  button.setAttribute("aria-label", strings.copyLabel);

  pre.before(wrapper);
  wrapper.append(pre, button);

  button.addEventListener("click", async () => {
    try {
      await copyText(code.textContent);
      button.textContent = strings.copied;
    } catch (_error) {
      button.textContent = strings.copyFailed;
    }

    window.setTimeout(() => {
      button.textContent = strings.copy;
    }, 1600);
  });
});
