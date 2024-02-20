# frozen_string_literal: true
require 'csv'
require_relative 'models'


class Slurp
  def initialize(gtfs:)
    @gtfs = gtfs
  end

  attr_reader :gtfs

  def setup
    make_tables
    import_data
  end

  def make_tables
    SetUpTables.new
      .migrate(:up)
  end

  def import_data
    puts 'importing repeat patterns'
    with_progress repeats do |r|
      r.save!
    end

    puts 'importing agencies'
    with_progress agencies do |a|
      a.save!
    end

    puts 'importing shapes'
    with_progress shapes do |s|
      Shape.upsert s.attributes
    end

    puts 'importing shape path points'
    with_progress path_points do |pp|
      pp.save!
    end

    puts 'importing stops'
    with_progress stops do |s|
      s.save!
    end

    puts 'importing routes'
    with_progress routes do |r|
      r.save!
    end

    puts 'importing blocks'
    with_progress blocks do |b|
      Block.upsert b.attributes
    end

    puts 'importing trips'
    with_progress trips do |t|
      t.save!
    end

    puts 'importing stop times'
    with_progress stop_times do |st|
      st.save!
    end
  end

  def agencies
    rows_from("#{gtfs}/agency.txt").map do |row|
      Agency.new(
        id: row['agency_id'],
        name: row['agency_name'],
        url: row['agency_url'],
        timezone: row['agency_timezone'],
        lang: row['agency_lang'],
        phone: row['agency_phone'],
        fare_url: row['agency_fare_url']
      )
    end
  end

  def shapes
    # normally i'd like it to be the database's job to unique these ids.
    # however, in the data i've been working with there are ~400 points per
    # shape. i would expect the overall count (~0.5k in my testing) to easily
    # fit in memory almost all of the time.
    rows_from("#{gtfs}/shapes.txt")
      .map { |row| row['shape_id'].to_i }
      .uniq
      .map { |id| Shape.new id: }
  end

  def path_points
    rows_from("#{gtfs}/shapes.txt").map do |row|
      PathPoint.new(
        shape_id: row['shape_id'],
        lat: row['shape_pt_lat'],
        lon: row['shape_pt_lon'],
        seq: row['shape_pt_sequence'],
        dist_traveled: row['shape_dist_traveled']
      )
    end
  end

  def repeats
    rows_from("#{gtfs}/calendar.txt").map do |row|
      st_y, st_m, st_d = row['start_date'].match(/^(\d{4})(\d\d)(\d\d)$/).captures
      en_y, en_m, en_d = row['end_date'].match(/^(\d{4})(\d\d)(\d\d)$/).captures

      Repeat.new(
        id: row['service_id'],
        monday: row['monday'],
        tuesday: row['tuesday'],
        wednesday: row['wednesday'],
        thursday: row['thursday'],
        friday: row['friday'],
        saturday: row['saturday'],
        sunday: row['sunday'],
        start_date: "#{st_y}-#{st_m}-#{st_d}",
        end_date: "#{en_y}-#{en_m}-#{en_d}"
      )
    end
  end

  def stops
    rows_from("#{gtfs}/stops.txt").map do |row|
      Stop.new(
        id: row['stop_id'],
        code: row['stop_code'],
        name: row['stop_name'],
        desc: row['stop_desc'],
        lat: row['stop_lat'],
        lon: row['stop_lon'],
        zone_id: row['zone_id'],
        url: row['stop_url'],
        location_type: row['location_type'],
        parent_station: row['parent_station'],
        timezone: row['stop_timezone'],
        wheelchair_boarding: row['wheelchair_boarding']
      )
    end
  end

  def routes
    rows_from("#{gtfs}/routes.txt").map do |row|
      Route.new(
        id: row['route_id'],
        agency_id: row['agency_id'],
        short_name: row['route_short_name'],
        long_name: row['route_long_name'],
        desc: row['route_desc'],
        type: row['route_type'],
        url: row['route_url'],
        color: row['route_color'],
        text_color: row['row_text_color']
      )
    end
  end

  def blocks
    rows_from("#{gtfs}/trips.txt").map do |row|
      Block.new(id: row['block_id'])
    end
  end

  def trips
    rows_from("#{gtfs}/trips.txt").map do |row|
      Trip.new(
        id: row['trip_id'],
        route_id: row['route_id'],
        shape_id: row['shape_id'],
        block_id: row['block_id'],
        repeat_id: row['service_id'],
        direction_id: row['direction_id'],
        headsign: row['trip_headsign'],
        short_name: row['trip_short_name'],
        peak_flag: row['peak_flag'],
        fare_id: row['fare_id'],
        wheelchair_accessible: row['wheelchair_accessible'],
        bikes_allowed: row['bikes_allowed']
      )
    end
  end

  def stop_times
    rows_from("#{gtfs}/stop_times.txt").map do |row|
      StopTime.new(
        trip_id: row['trip_id'],
        stop_id: row['stop_id'],
        arrival: row['arrival_time'],
        departure: row['departure_time'],
        seq: row['stop_sequence'],
        headsign: row['stop_headsign'],
        pickup_type: row['pickup_type'],
        dropoff_type: row['drop_off_type'],
        dist_traveled: row['shape_dist_traveled'],
        timepoint: row['timepoint']
      )
    end
  end

  private

  def rows_from file
    CSV.foreach(file, headers: true).lazy
  end

  def with_progress enum
    enum.each_with_index do |item, i|
      print '.' if (i + 1) % 1000 == 0
      yield item
    end

    print "\n"
  end
end


class SetUpTables < ActiveRecord::Migration[6.0]
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :url
      t.string :timezone
      t.string :lang
      t.string :phone
      t.string :fare_url
    end

    # i see the shapes
    # i remember from maps
    create_table :shapes do |t|
      # just the default id
    end

    create_table :path_points do |t|
      t.references :shape, foreign_key: true
      t.decimal :lat
      t.decimal :lon
      t.integer :seq
      t.decimal :dist_traveled
    end

    create_table :repeats do |t|
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday
      t.date :start_date
      t.date :end_date
    end

    create_table :stops do |t|
      t.integer :code # ?
      t.string :name
      t.string :desc
      t.decimal :lat
      t.decimal :lon
      t.integer :zone_id # -> ?
      t.string :url
      t.integer :location_type # ?
      t.integer :parent_station # -> ?
      t.string :timezone
      t.boolean :wheelchair_boarding
    end

    create_table :routes do |t|
      t.references :agency, foreign_key: true
      t.string :short_name
      t.string :long_name
      t.string :desc
      t.string :type # ?
      t.string :url
      t.string :color
      t.string :text_color
    end

    create_table :blocks do |t|
      # just the default id
    end

    create_table :trips do |t|
      t.references :route, foreign_key: true
      t.references :shape, foreign_key: true
      t.references :block, foreign_key: true
      t.references :repeat, foreign_key: true
      t.integer :direction_id # -> ?
      t.string :headsign
      t.string :short_name
      t.integer :peak_flag
      t.integer :fare_id # -> ?
      t.boolean :wheelchair_accessible
      t.boolean :bikes_allowed
    end

    create_table :stop_times do |t|
      t.references :trip, foreign_key: true
      t.references :stop, foreign_key: true
      t.time :arrival
      t.time :departure
      t.integer :seq
      t.string :headsign
      t.integer :pickup_type # ?
      t.integer :dropoff_type # ?
      t.decimal :dist_traveled
      t.boolean :timepoint
    end
  end
end
