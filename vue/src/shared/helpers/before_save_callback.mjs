export function registerBeforeSaveCallback(model, callback) {
  if (!model?.beforeSaves) return () => {};

  if (!model.beforeSaves.includes(callback)) model.beforeSaves.push(callback);

  return () => {
    const index = model.beforeSaves.indexOf(callback);
    if (index !== -1) model.beforeSaves.splice(index, 1);
  };
}
