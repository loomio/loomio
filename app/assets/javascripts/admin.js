document.addEventListener("submit", (event) => {
  let message = event.target.dataset.confirm;
  if (event.target.dataset.bulkUserAction) {
    message = event.target.querySelector("input[name=operation]:checked")?.dataset.confirm;
  }
  if (message && !window.confirm(message)) event.preventDefault();
});

document.addEventListener("change", (event) => {
  const inputName = event.target.dataset.selectAll;
  if (!inputName) return;

  event.target.closest("form").querySelectorAll(`input[name="${inputName}"]`).forEach((input) => {
    input.checked = event.target.checked;
  });
});
