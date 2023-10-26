import { differenceInHours, formatDistanceStrict, isSameYear, isValid, parse } from 'date-fns';
import { format, utcToZonedTime } from 'date-fns-tz';
import defaultLocale from 'date-fns/locale/en-US';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import i18n from '@/i18n';

i18n.dateLocale = defaultLocale;

export var day = function(date, zone) {
  if (!isValid(date)) { throw {"invalid date": "invalid date", date}; }
  return format(utcToZonedTime(date, zone), 'EEE', {timeZone: zone, locale: i18n.dateLocale});
};

export var approximate = function(date, zone, dateTimePref) {
  if (zone == null) { zone = AppConfig.timeZone; }
  if (dateTimePref == null) { ({
    dateTimePref
  } = Session.user()); }
  if (!isValid(date)) { throw {"invalid date": "invalid date", date}; }

  const localFormat = pattern => format(utcToZonedTime(date, zone), pattern, {timeZone: zone, locale: i18n.dateLocale});

  const now = new Date;
  if (differenceInHours(now, date) < 24) {
    return formatDistanceStrict(date, new Date(), {addSuffix: true, locale: i18n.dateLocale});
  } else if (isSameYear(date, now)) {
    return format(date, "MMMM d", {locale: i18n.dateLocale});
  } else {
    switch (dateTimePref) {
      case 'day_iso': case 'iso':
        return localFormat('yyyy-MM-dd');
      case 'abbr': case 'day_abbr':
        return localFormat("d LLL yyyy");
      default:
        return console.error('unknown date pref');
    }
  }
};


export var exact = function(date, zone, dateTimePref) {
  if (zone == null) { zone = AppConfig.timeZone; }
  if (dateTimePref == null) { ({
    dateTimePref
  } = Session.user()); }
  if (!isValid(date)) { throw {"invalid date": "invalid date", date}; }

  const spacePadHour = function() {
    const pad = parseInt(format(utcToZonedTime(date, zone), "h", {timeZone: zone, locale: i18n.dateLocale})) < 10;
    if (pad) { return ' '; } else { return ''; }
  };

  const spacePadDay = function() {
    const pad = parseInt(format(utcToZonedTime(date, zone), "d", {timeZone: zone, locale: i18n.dateLocale})) < 10;
    if (pad) { return ' '; } else { return ''; }
  };

  const localFormat = pattern => format(utcToZonedTime(date, zone), pattern, {timeZone: zone, locale: i18n.dateLocale});

  switch (dateTimePref) {
    case 'day_iso':
      return localFormat('E yyyy-MM-dd HH:mm');
    case 'abbr':
      return localFormat(`${spacePadDay()}d LLL yyyy ${spacePadHour()}h:mma`);
    case 'day_abbr':
      return localFormat(`E ${spacePadDay()}d LLL yyyy ${spacePadHour()}h:mma`);
    case 'iso':
      return localFormat('yyyy-MM-dd HH:mm');
    default:
      return console.error('unknown date pref');
  }
};

export var hoursOfDay = () => [
  "00:00",
  "01:00",
  "02:00",
  "03:00",
  "04:00",
  "05:00",
  "06:00",
  "07:00",
  "08:00",
  "09:00",
  "10:00",
  "11:00",
  "12:00",
  "13:00",
  "14:00",
  "15:00",
  "16:00",
  "17:00",
  "18:00",
  "19:00",
  "20:00",
  "21:00",
  "22:00",
  "23:00",
  "23:59"
];

export var timeline = date => format(date, "yyyy-MM-dd");

export var timeFormat = function() {
  if (Session.user().dateTimePref.includes('abbr')) {
    return 'h:mm a';
  } else {
    return 'HH:mm';
  }
};
