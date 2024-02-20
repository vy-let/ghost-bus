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

### Weekly Mean Headway

The mean headway is a rough measure of the level of service of a line. It provides a fair, combined answer to the questions:

1. How often does it run?
2. How many hours is it in service?

To calculate it for some line "N":

``` fish
./ghost-bus mean-headway N
```

The output is divided into the line's **segments** — see below.

It does not address the *reliability* of the service, as it doesn't consider how much variability in headway there is in the day, how long service gaps are, etc. It should be treated as a comparative measure of the **quantity** of service provided.


### Segments and Variations

Suppose you have a line, and you want to find out all the different routes it can take. For instance, your line 2 might start at station A, pass stations B, C, and D, and then fork, either going to stations E and F, or to station G. However, in addition to the fork after D, some inbound trips may only start at C, skipping A and B entirely. Ghost-bus can identify all the actual routing variations that the line takes:

``` fish
./ghost-bus variations 2 inbound
```

produces:

```
[inbound: A -> F (6 stops)]
[inbound: C -> F (4 stops)]
[inbound: A -> G (5 stops)]
```

Similarly, you may want to divide up the line into segments, each having the same "timbre," or set of variations that visit each stop:

``` fish
./ghost-bus segments 2 inbound
```

produces:

```
[inbound: A -> B (2 stops)]
[inbound: C -> D (2 stops)]
[inbound: E -> F (2 stops)]
[inbound: G (1 stop)]
```

This can be useful for mapping purposes, or identifying where the line needs different calculations for frequency, for example.


### Explore

You can explore the data yourself using friendly ActiveRecord bindings. Open up a ruby shell

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
