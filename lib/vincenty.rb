module Vincenty
  class FailToConverge < StandardError; end

  module Trigonometry
    def deg_to_rad(angle_in_degrees)
      angle_in_degrees * Math::PI / 180
    end
  end

  extend Trigonometry

  EQUATORIAL_RADIUS = 6_378_137.0
  POLAR_RADIUS      = 6_356_752.31424518
  FLATTENING = (EQUATORIAL_RADIUS - POLAR_RADIUS) / EQUATORIAL_RADIUS

  CONVERGENCE_THRESHOLD = 1e-12 # i.e. 0.06 mm error
  MAX_ITERATIONS = 200

  def distance_between_points(first, second)
    lat1 = deg_to_rad(first[:latitude])
    lon1 = deg_to_rad(first[:longitude])
    lat2 = deg_to_rad(second[:latitude])
    lon2 = deg_to_rad(second[:longitude])

    return 0 if lat1 == lat2 && lon1 == lon2

    lat1_sign = lat1.negative? ? -1 : 1
    geodetic_lat1 = if (Math::PI / 2 - lat1.abs).abs < 1.0e-10
                      lat1_sign * (Math::PI / 2 - 1e-10)
                    else
                      lat1
                    end

    lat2_sign = lat2.negative? ? -1 : 1
    geodetic_lat2 = if (Math::PI / 2 - lat2.abs).abs < 1.0e-10
                      lat2_sign * (Math::PI / 2 - 1e-10)
                    else
                      lat2
                    end

    difference_in_longitude = (lon2 - lon1).abs
    if difference_in_longitude > Math::PI
      difference_in_longitude = 2 * Math::PI - difference_in_longitude
    end

    # latitude on the auxiliary sphere
    reduced_latitude1 = Math.atan((1 - FLATTENING) * Math.tan(geodetic_lat1))
    reduced_latitude2 = Math.atan((1 - FLATTENING) * Math.tan(geodetic_lat2))

    sin_reduced_latitude1 = Math.sin(reduced_latitude1)
    cos_reduced_latitude1 = Math.cos(reduced_latitude1)
    sin_reduced_latitude2 = Math.sin(reduced_latitude2)
    cos_reduced_latitude2 = Math.cos(reduced_latitude2)

    lambda_v = difference_in_longitude
    iteration_index = 0

    while iteration_index < MAX_ITERATIONS
      sin_lambda_v = Math.sin(lambda_v)
      cos_lambda_v = Math.cos(lambda_v)

      sin_sigma = Math.sqrt(
        (cos_reduced_latitude2 * sin_lambda_v)**2 +
        (cos_reduced_latitude1 * sin_reduced_latitude2 -
         sin_reduced_latitude1 * cos_reduced_latitude2 * cos_lambda_v)**2
      )

      cos_sigma =
        sin_reduced_latitude1 * sin_reduced_latitude2 +
        cos_reduced_latitude1 * cos_reduced_latitude2 * cos_lambda_v

      sigma = Math.atan2(sin_sigma, cos_sigma)
      sin_alpha = cos_reduced_latitude1 * cos_reduced_latitude2 * sin_lambda_v / sin_sigma
      cos_sq_alpha = 1 - sin_alpha * sin_alpha
      cos_2_sigma_m = cos_sigma - 2 * sin_reduced_latitude1 * sin_reduced_latitude2 / cos_sq_alpha
      cos_2_sigma_m = 0 if cos_2_sigma_m.nan?
      c = FLATTENING / 16 * cos_sq_alpha * (4 + FLATTENING * (4 - 3 * cos_sq_alpha))

      lambda_prev = lambda_v
      # use cos_2_sigma_m=0 when over equatorial lines
      lambda_v =
        difference_in_longitude +
        (1 - c) * FLATTENING * sin_alpha * (sigma + c * sin_sigma *
                                            (cos_2_sigma_m + c * cos_sigma *
                                             (-1 + 2 * cos_2_sigma_m * cos_2_sigma_m)))

      break if (lambda_v - lambda_prev).abs < CONVERGENCE_THRESHOLD

      iteration_index += 1
    end

    raise FailToConverge if (lambda_v - lambda_prev).abs > CONVERGENCE_THRESHOLD

    u_sq = cos_sq_alpha * (EQUATORIAL_RADIUS**2 - POLAR_RADIUS**2) / POLAR_RADIUS**2
    a1 = 1 + u_sq / 16_384 * (4096 + u_sq * (-768 + u_sq * (320 - 175 * u_sq)))
    b1 = u_sq / 1024 * (256 + u_sq * (-128 + u_sq * (74 - 47 * u_sq)))
    delta_sigma = b1 * sin_sigma * (cos_2_sigma_m + b1 / 4 * (cos_sigma *
                  (-1 + 2 * cos_2_sigma_m * cos_2_sigma_m) - b1 / 6 * cos_2_sigma_m *
                  (-3 + 4 * sin_sigma * sin_sigma) * (-3 + 4 * cos_2_sigma_m * cos_2_sigma_m)))

    distance = POLAR_RADIUS * a1 * (sigma - delta_sigma)

    return distance
  end
  module_function :distance_between_points
end
