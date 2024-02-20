# frozen_string_literal: true
require_relative 'models'
require_relative 'segments'
require_relative 'time_display'

class Headway
  def initialize route
    @route = route
  end

  attr_reader :route


  def display_weekly_mean
    weekly_mean.each do |segment, headway|
      duration = TimeDisplay.duration headway
      puts "#{duration}: \t#{segment.inspect}"
    end
    nil
  end

  def display_weekly_trips
    weekly_trips.each do |segment, trips|
      puts "#{trips}: \t#{segment.inspect}"
    end
    nil
  end


  def weekly_mean
    weekly_trips.map do |segment, trips|
      next [segment, nil] if trips == 0

      [segment, (1.week / trips)]
    end
  end

  def weekly_trips
    segment_trips = all_segments.map do |segment|
      stop = segment.first
      trips = stop.trips
                .for_route(route)
                .in_direction(segment.dir)
                .preload(:repeat)
                .sum { |trip| trip.repeat.days.count }

      [segment, trips]
    end

    segment_trips.sort_by { |segment, trips| [segment.dir, -trips] }
      .to_h
  end


  def directional_segmenters
    route.directions.map do |dir|
      Segments.new route, dir:
    end
  end

  def all_segments
    @all_segments ||= directional_segmenters.flat_map(&:segments)
  end
end
