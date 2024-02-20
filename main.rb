# frozen_string_literal: true

class Main
  def self.main
    if help?
      $stderr.puts <<~HELP
        $ ghost-bus import path/to/unzipped/gtfs/data
        $ ghost-bus mean-headway 60
        $ ghost-bus segments 2 outbound
        $ ghost-bus variations 14 outbound
      HELP
      return
    end

    require_relative 'lib/db_connection'
    DBConnection.connect db_file

    case verb
    when 'import'
      require_relative 'lib/slurp'
      Slurp.new(gtfs:).setup

    when 'segments'
      require_relative 'lib/segments'
      directions.each do |direction|
        Segments.new(route, dir: direction).display_segments
      end

    when 'variations'
      require_relative 'lib/segments'
      directions.each do |direction|
        Segments.new(route, dir: direction).display_variations
      end

    when 'mean-headway'
      require_relative 'lib/headway'
      Headway.new(route).display_weekly_mean

    else
      $stderr.puts 'i don’t know what you want me to do. try `--help`'
    end

  rescue Exception => e
    # Silence backtrace on exceptions unless requested
    $stderr.puts e.inspect
    $stderr.puts(e.backtrace) if show_trace?
  end


  def self.help?
    ARGV.intersection(['--help', '-h']).any?
  end

  def self.verb
    ARGV.first
  end

  def self.db_file
    './db.sqlite3'
  end

  def self.gtfs
    ARGV[1]
  end

  def self.route
    require_relative 'lib/models'
    Route.find_by(short_name: ARGV[1])
  end

  def self.directions
    case ARGV[2]
    when 'outbound', '0'
      [0]
    when 'inbound', '1'
      [1]
    when nil, ''
      route.directions
    else
      Integer(ARGV[2])
    end
  end

  def self.show_trace?
    ARGV.include? '--show-trace'
  end
end
