export function pollReminderItems(t) {
  return [
    ['nobody', 'nobody'],
    ['author', 'author'],
    ['voters_uncast', 'people_who_have_not_voted'],
    ['voters', 'voters']
  ].map(([value, label]) => ({
    value,
    title: t(`poll_common_settings.notify_on_closing_soon.${label}`)
  }));
}
