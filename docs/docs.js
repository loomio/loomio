const sidebarToggle = document.querySelector(".sidebar-toggle");
const sidebarScrim = document.querySelector(".sidebar-scrim");

function setNavigationOpen(open) {
  document.body.classList.toggle("navigation-open", open);
  sidebarToggle?.setAttribute("aria-expanded", String(open));
  sidebarToggle?.setAttribute("aria-label", open ? "Close navigation" : "Open navigation");
}

sidebarToggle?.addEventListener("click", () => {
  setNavigationOpen(!document.body.classList.contains("navigation-open"));
});

sidebarScrim?.addEventListener("click", () => setNavigationOpen(false));

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") setNavigationOpen(false);
});

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
  button.textContent = "Copy";
  button.setAttribute("aria-label", "Copy code to clipboard");

  pre.before(wrapper);
  wrapper.append(pre, button);

  button.addEventListener("click", async () => {
    try {
      await copyText(code.textContent);
      button.textContent = "Copied";
    } catch (_error) {
      button.textContent = "Copy failed";
    }

    window.setTimeout(() => {
      button.textContent = "Copy";
    }, 1600);
  });
});
