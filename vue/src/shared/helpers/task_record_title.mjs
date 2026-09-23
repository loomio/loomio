export function taskRecordTitle(record) {
  if (record.isA('comment')) return record.topic().title;
  if (record.isA('outcome')) return record.poll().title;
  if (record.isA('group')) return record.name;

  return record.title;
}
