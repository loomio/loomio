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
    'MMMM d, HH:mm'
  else
    'yyyy MMMM d, HH:mm'
  format(utcToZonedTime(date, zone), formatStr, {timeZone: zone, locale: i18n.dateLocale})

export hoursOfDay = [
  "00:00"
  "01:00"
  "02:00"
  "03:00"
  "04:00"
  "05:00"
  "06:00"
  "07:00"
  "08:00"
  "09:00"
  "10:00"
  "11:00"
  "12:00"
  "13:00"
  "14:00"
  "15:00"
  "16:00"
  "17:00"
  "18:00"
  "19:00"
  "20:00"
  "21:00"
  "22:00"
  "23:00"
]
