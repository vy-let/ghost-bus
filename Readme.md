ghost-bus
=========

Tool to analyze transit schedules based on [GTFS Schedule][gtfs] data. This is mainly for my own playing around, so it's not meant to support a lot of edge cases. If you find it useful, all the better.


Usage
-----

### Setup

Ensure you have the dependencies installed:

``` fish
nix develop
```

Grab schedule data from your transit agency — for example, [Sound Transit][stotd] — and unzip it. Further steps will refer to this unzipped folder.

### Import

The first step to using this tool is to import the schedule data into a local sqlite database:

``` fish
./ghost-bus import ~/Downloads/gtfs_kcm
```

### Explore

Automatic statistics calculation isn't implemented yet. Open up a ruby shell

``` fish
irb
```

then import the repl dependencies, and explore

``` ruby
require_relative 'repl'
#=> true

the_sixty = Route.find_by(short_name: '60')
#=> #<Route:0x00000001099ccbd8 id: 100249, agency_id: 1, short_name: "60", long_name: "", desc: "Westwood Village - Georgetown - Broadway", type: "3", ...>

the_sixty.trips.first
#=> #<Trip:0x000000010980d798 id: 546779985, route_id: 100249, block_id: 7087437, service_id: 45626, direction_id: 0, headsign: "Westwood Village N Beacon Hill"...>
```

or use sqlite directly

``` fish
sqlite3 db.sqlite3
```



[gtfs]: https://gtfs.org/schedule/reference/
[stotd]: https://www.soundtransit.org/help-contacts/business-information/open-transit-data-otd/otd-downloads
