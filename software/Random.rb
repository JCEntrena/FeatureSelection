#!/usr/bin/env ruby
#encoding: utf-8

module FeatureSelection

  class GetRandom
    # Get pseudo-random solutions
    def randomSolution(tam, seed)
      b_vector = Array.new(tam, 0)
      tam.times do |i|
        if Random.new(i*seed + seed).rand < 0.5
          b_vector[i] = 1
        end
      end
      b_vector
    end

  end
end
