# frozen_string_literal: true
require 'bigdecimal'

class TimeDisplay
  def self.duration dur
    left = dur

    days = left.in_days.floor
    left -= days.days

    hours = left.in_hours.floor
    left -= hours.hours

    minutes = left.in_minutes
    minute_dec = (days + hours) > 0 ?
                   minutes.round :
                   minutes.to_d.round(1)
    minute_s = minute_dec.is_a?(BigDecimal) ?
                 minute_dec.to_s('F') :
                 minute_dec.to_s

    [
      (pluralize(days, 'day') if days > 0),
      (pluralize(hours, 'hour') if hours > 0),
      pluralize(minute_dec, 'minute', minute_s)
    ].compact.join(' ')
  end

  def self.pluralize dur, term, dur_s = nil
    plural = 's' if dur != 1

    "#{dur_s || dur} #{term}#{plural}"
  end
end
