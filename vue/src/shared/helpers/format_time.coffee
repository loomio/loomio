import { differenceInHours, formatDistanceStrict, isSameYear, isValid } from 'date-fns'
import { format, utcToZonedTime } from 'date-fns-tz'
import defaultLocale from 'date-fns/locale/en-US'
import AppConfig from '@/shared/services/app_config'
import i18n from '@/i18n'

i18n.dateLocale = defaultLocale

# human friendly date format
# given a date
# when within 24 hours... give time ago in hours/minutes
# when same year give month and date
# otherwise give iso formatted date

export approximate = (date, zone) ->
  throw {"invalid date", date} unless isValid(date)
  now = new Date
  if differenceInHours(now, date) < 24
    formatDistanceStrict(date, new Date(), {addSuffix: true, locale: i18n.dateLocale})
  else if isSameYear(date, now)
    format(date, "MMMM d", {locale: i18n.dateLocale})
  else
    format(date, "yyyy-MM-dd")

export exact = (date, zone = AppConfig.timeZone) ->
  throw {"invalid date", date} unless isValid(date)
  now = new Date
  formatStr = if isSameYear(date, now)
    'MMMM d, h:mm a'
  else
    'yyyy MMMM d, h:mm a'
  format(utcToZonedTime(date, zone), formatStr, {timeZone: zone, locale: i18n.dateLocale})

export hoursOfDay = [
  "12:00 AM"
  "01:00 AM"
  "02:00 AM"
  "03:00 AM"
  "04:00 AM"
  "05:00 AM"
  "06:00 AM"
  "07:00 AM"
  "08:00 AM"
  "09:00 AM"
  "10:00 AM"
  "11:00 AM"
  "12:00 PM"
  "01:00 PM"
  "03:00 PM"
  "04:00 PM"
  "05:00 PM"
  "06:00 PM"
  "07:00 PM"
  "08:00 PM"
  "09:00 PM"
  "10:00 PM"
  "11:00 PM"
]
