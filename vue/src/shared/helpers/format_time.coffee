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
  "1:00 AM"
  "2:00 AM"
  "3:00 AM"
  "4:00 AM"
  "5:00 AM"
  "6:00 AM"
  "7:00 AM"
  "8:00 AM"
  "9:00 AM"
  "10:00 AM"
  "11:00 AM"
  "12:00 PM"
  "1:00 PM"
  "2:00 PM"
  "3:00 PM"
  "4:00 PM"
  "5:00 PM"
  "6:00 PM"
  "7:00 PM"
  "8:00 PM"
  "9:00 PM"
  "10:00 PM"
  "11:00 PM"
]
