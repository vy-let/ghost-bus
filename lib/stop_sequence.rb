# frozen_string_literal: true

class StopSequence
  include Enumerable

  def initialize(stops, dir:)
    @stops = stops
    @dir = dir
  end

  attr_reader :stops, :dir
  delegate :each, :last, :index, to: :stops

  def inspect
    if stops.none?
      "[#{pretty_boundness}: (0 stops)]"
    elsif stops.one?
      "[#{pretty_boundness}: #{first.name} (1 stop)]"
    else
      "[#{pretty_boundness}: #{first.name} -> #{last.name} (#{stops.size} stops)]"
    end
  end

  def pretty_boundness
    case dir
    when 0
      'outbound'
    when 1
      'inbound'
    else
      "#{dir}-bound"
    end
  end
end
