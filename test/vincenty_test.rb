require 'minitest/autorun'
require 'vincenty'

class VincentyDistanceTest < Minitest::Test
  # (0.0, 0.0) -> (0.0, 0.0) = 0
  def test_distance_to_the_same_point
    start  = { latitude: 0.0, longitude: 0.0 }
    finish = { latitude: 0.0, longitude: 0.0 }

    distance = Vincenty.distance_between_points(start, finish)

    assert_equal 0, distance
  end

  # (0.0, 0.0) -> (0.0, 1.0) = 111_319.491
  def test_distance_to_one_deg
    start  = { latitude: 0.0, longitude: 0.0 }
    finish = { latitude: 0.0, longitude: 1.0 }

    distance = Vincenty.distance_between_points(start, finish)

    assert_in_delta 111_319.491, distance, 0.001
  end

  # slow  converge
  # (0.0, 0.0) -> (0.5, 179.5) = 19_936_288.579'
  def test_slow_converge
    start  = { latitude: 0.0, longitude: 0.0 }
    finish = { latitude: 0.5, longitude: 179.5 }

    distance = Vincenty.distance_between_points(start, finish)

    assert_in_delta 19_936_288.579, distance, 0.001
  end

  # (0.0, 0.0) -> (0.5, 179.7)
  def test_failure_to_converge
    start  = { latitude: 0.0, longitude: 0.0 }
    finish = { latitude: 0.5, longitude: 179.7 }

    assert_raises Vincenty::FailToConverge do
      Vincenty.distance_between_points(start, finish)
    end
  end

  # boston -> new york = 298_396.057
  def test_distance_between_boston_and_new_york
    boston   = { latitude: 42.3541165, longitude: -71.0693514 }
    new_york = { latitude: 40.7791472, longitude: -73.9680804 }

    distance = Vincenty.distance_between_points(boston, new_york)

    assert_in_delta 298_396.057, distance, 0.001
  end

  # calcs distance verified by FAI and Flysight Viewer
  def test_verified_by_fai_distance
    start  = { latitude: 44.34980359273743, longitude: 12.17773479543761 }
    finish = { latitude: 44.35679018739903, longitude: 12.21939248804523 }

    distance = Vincenty.distance_between_points(start, finish)

    assert_in_delta 3410.841, distance, 0.001
  end
end
