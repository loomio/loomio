import { differenceInHours, formatDistanceStrict, isSameYear, isValid, parse } from 'date-fns'
import { format, utcToZonedTime } from 'date-fns-tz'
import defaultLocale from 'date-fns/locale/en-US'
import AppConfig from '@/shared/services/app_config'
import Session from '@/shared/services/session'
import i18n from '@/i18n'

i18n.dateLocale = defaultLocale

export day = (date, zone) ->
  throw {"invalid date", date} unless isValid(date)
  format(utcToZonedTime(date, zone), 'EEE', {timeZone: zone, locale: i18n.dateLocale})

export approximate = (date, zone = AppConfig.timeZone, dateTimePref = Session.user().dateTimePref) ->
  throw {"invalid date", date} unless isValid(date)

  localFormat = (pattern) ->
    format(utcToZonedTime(date, zone), pattern, {timeZone: zone, locale: i18n.dateLocale})

  now = new Date
  if differenceInHours(now, date) < 24
    formatDistanceStrict(date, new Date(), {addSuffix: true, locale: i18n.dateLocale})
  else if isSameYear(date, now)
    format(date, "MMMM d", {locale: i18n.dateLocale})
  else
    switch dateTimePref
      when 'day_iso', 'iso'
        localFormat('yyyy-MM-dd')
      when 'abbr', 'day_abbr'
        localFormat("d LLL yyyy")
      else
        console.error('unknown date pref')


export exact = (date, zone = AppConfig.timeZone, dateTimePref = Session.user().dateTimePref) ->
  throw {"invalid date", date} unless isValid(date)

  spacePadHour = ->
    pad = parseInt(format(utcToZonedTime(date, zone), "h", {timeZone: zone, locale: i18n.dateLocale})) < 10
    if pad then ' ' else ''

  spacePadDay = ->
    pad = parseInt(format(utcToZonedTime(date, zone), "d", {timeZone: zone, locale: i18n.dateLocale})) < 10
    if pad then ' ' else ''

  localFormat = (pattern) ->
    format(utcToZonedTime(date, zone), pattern, {timeZone: zone, locale: i18n.dateLocale})

  switch dateTimePref
    when 'day_iso'
      localFormat('E yyyy-MM-dd HH:mm')
    when 'abbr'
      localFormat("#{spacePadDay()}d LLL yyyy #{spacePadHour()}h:mma")
    when 'day_abbr'
      localFormat("E #{spacePadDay()}d LLL yyyy #{spacePadHour()}h:mma")
    when 'iso'
      localFormat('yyyy-MM-dd HH:mm')
    else
      console.error('unknown date pref')

export hoursOfDay = -> 
  times = [
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
    "23:59"
  ]
  if Session.user().dateTimePref.includes('abbr')
    times.map (s) -> format(parse(s, 'HH:mm', new Date()), "h:mm a", {locale: i18n.dateLocale})
  else
    times

export timeline = (date) -> format(date, "yyyy-MM-dd")

export timeFormat = ->
    if Session.user().dateTimePref.includes('abbr')
      'h:mm a'
    else
      'HH:mm'
