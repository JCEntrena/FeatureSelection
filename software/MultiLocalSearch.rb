#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'LocalSearch.rb'

module FeatureSelection

  class MultiLocalSearch < LocalSearch

    def solve(dataset, first, seed = 1)
      @classifier = Classifier.new
      best_value = -1
      best_solution = []
      15.times do |j|
        time = Time.now
        solution = super(dataset, first, seed + j)
        value = @classifier.classify(dataset, solution, first)
        if value > best_value
          best_value = value
          best_solution = Array.new(solution)
        end
      end
      best_solution
    end
  end
end
