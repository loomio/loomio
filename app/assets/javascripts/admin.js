document.addEventListener("submit", (topic_item) => {
  const message = topic_item.target.dataset.confirm;
  if (message && !window.confirm(message)) topic_item.preventDefault();
});
