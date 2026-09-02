export function notificationVolumeContext(model) {
  if (model.isA('topic')) return 'thread';
  if (model.isA('membership')) return 'group';
  return 'default';
}

export function notificationVolumeTitleKey(model) {
  return `change_volume_form.context_title.${notificationVolumeContext(model)}`;
}

export function notificationCatchUpTitleKey(emailCatchUpDay) {
  if (emailCatchUpDay === 7) return 'strand_nav.daily_catch_up_email';
  if (emailCatchUpDay === 8) return 'strand_nav.catch_up_email_every_second_day';
  return 'strand_nav.weekly_catch_up_email';
}

export function notificationVolumeOptionTitleKey(volume, channel, emailCatchUpEnabled) {
  if (volume === 'quiet') {
    if (channel === 'email' && emailCatchUpEnabled) return 'change_volume_form.catch_up_only_option';
    return `change_volume_form.no_${channel}_updates_option`;
  }
  if (volume === 'normal') return 'change_volume_form.when_notified_option';
  return 'change_volume_form.all_activity_option';
}

export function notificationVolumeOptionDescriptionKey(volume, channel, emailCatchUpEnabled) {
  if (volume === 'quiet') {
    if (channel === 'email' && emailCatchUpEnabled) return 'change_volume_form.catch_up_only_with_notifications_description';
    return `change_volume_form.no_${channel}_updates_description`;
  }
  if (volume === 'normal') {
    const catchUpSuffix = channel === 'email' && emailCatchUpEnabled ? '_with_catch_up' : '';
    return `change_volume_form.${channel}_when_notified${catchUpSuffix}_description`;
  }
  return `change_volume_form.${channel}_all_activity_description`;
}

export function notificationVolumeContextKey(model) {
  return `change_volume_form.context.${notificationVolumeContext(model)}`;
}
