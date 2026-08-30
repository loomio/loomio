export function notificationVolumeContext(model) {
  if (model.isA('topic')) return 'thread';
  if (model.isA('membership')) return 'group';
  return 'default';
}

export function notificationVolumeTitleKey(model) {
  return `change_volume_form.context_title.${notificationVolumeContext(model)}`;
}

export function notificationVolumeOptionTitleKey(volume, channel, catchUpEnabled) {
  if (volume === 'quiet') {
    if (catchUpEnabled) return 'change_volume_form.catch_up_only_option';
    return `change_volume_form.no_${channel}_updates_option`;
  }
  if (volume === 'normal') return 'change_volume_form.when_notified_option';
  return 'change_volume_form.all_activity_option';
}

export function notificationVolumeOptionDescriptionKey(volume, channel, catchUpEnabled) {
  if (volume === 'quiet') {
    if (catchUpEnabled) return 'change_volume_form.catch_up_only_with_notifications_description';
    return `change_volume_form.no_${channel}_updates_description`;
  }
  if (volume === 'normal') {
    const catchUpSuffix = catchUpEnabled ? '_with_catch_up' : '';
    return `change_volume_form.${channel}_when_notified${catchUpSuffix}_description`;
  }
  return `change_volume_form.${channel}_all_activity_description`;
}

export function notificationVolumeContextKey(model) {
  return `change_volume_form.context.${notificationVolumeContext(model)}`;
}
