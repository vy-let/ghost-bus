# frozen_string_literal: true
require_relative 'models'
require_relative 'stop_sequence'

class Segments
  def initialize(route, dir:)
    @route = route
    @dir = dir
  end

  attr_reader :route, :dir


  def display_variations
    variations.each do |v|
      puts v.inspect
    end
    nil
  end

  def display_segments
    segments.each do |s|
      puts s.inspect
    end
    nil
  end


  # find every unique sequence of stops that the route hits
  def variations
    @variations ||=
      route.trips.in_direction(dir)
        .lazy
        .map { |trip| trip.stops.to_a }
        .uniq
        .map { |stops| StopSequence.new stops, dir: }
        .to_a
  end

  # find every segment of the route that's served by a different set of
  # route variations
  def segments
    # this really feels like separating the yolk from the whites of an
    # egg---tossing it back and forth, terrified that something's gonna break
    # open, and really getting the feeling that there's some mathematical
    # identity here that would simplify the process.
    #
    # at least... that's how separating egg whites feels to me.

    # 1. find the set of variations that visit each stop. this set of
    #    variations will be the "timbre" of the line.
    #
    # => { Stop => [Variations] }
    stop_variations = Hash.new { |h, k| h[k] = Set.new }

    # tread carefully here, because variations only have equality by object identity
    variations.each do |variation|
      variation.each do |stop|
        stop_variations[stop] << variation
      end
    end

    # 2. partition the stops by the timbre of the line as it visits each
    #    one. each stop partitioning is a segment.
    #
    # => { [Variations] => [Stops] }
    variation_set_segments = Hash.new { |h, k| h[k] = Set.new }

    stop_variations.each do |stop, variations|
      variation_set_segments[variations] << stop
    end

    # 3. reset the ordering of stops within each segment to match the actual
    #    order the line visits them. this is stored in the source variations
    #    that are applicable to each segment.
    #
    # => [Segments]
    variation_set_segments.map do |variations, stops_set|
      # all variations making up the timbre of the segment will necessarily
      # contain all stops, so we can choose any to pull ordering from
      variation = variations.first
      stops = stops_set.sort { |a, b| variation.index(a) <=> variation.index(b) }

      StopSequence.new(stops, dir:)
    end
  end
end
