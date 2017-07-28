# Vincenty

Calculate the geographical distance (in meters) between 2 points
with extreme accuracy.

This library implements Vincenty's solution to the inverse geodetic problem. It
is based on the WGS 84 reference ellipsoid and is accurate to within 1 mm (!) or
better.

This formula is widely used in geographic information systems (GIS) and is much
more accurate than methods for computing the great-circle distance (which assume
a spherical Earth).

## Installation

Include the gem in your Gemfile:

```ruby
gem 'vincenty_distance'
```

or

        $ gem install vincenty_distance

and 

```ruby
require 'vincenty'
```

## Example: distance between Boston and New York City

```ruby

require 'vincenty'

boston  = { latitude: 42.3541165, longitude: -71.0693514 }
newyork = { latitude: 40.7791472, longitude: -73.9680804 }

distance = Vincenty.distance_between_points(boston, newyork)

# distance =  298_396.057 m
```

## References

[Wikipedia: Vincenty's formulae](https://en.wikipedia.org/wiki/Vincenty's_formulae)

[Wikipedia: World Geodetic System](https://en.wikipedia.org/wiki/World_Geodetic_System)

[Python implementation](https://github.com/maurycyp/vincenty)
