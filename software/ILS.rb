#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'
require_relative 'LocalSearch.rb'

module FeatureSelection

  class ILS

    def modify(array, first, modifications, max, seed)
      new_array = Array.new(array)
      # Getting changes, not considering class.
      changes = first ? (1..array.length-1).to_a : (0..array.length-2).to_a
      # Shuffle, taking first m, changing value.
      changes.shuffle(random: Random.new(seed)).first(modifications).each do |i|
        new_array[i] = (new_array[i] - 1).abs
      end
      new_array
    end

    def solve(dataset, first, seed = 1)
      @classifier = Classifier.new
      # For random initial solution
      @random = GetRandom.new
      # For Local Search
      @local = LocalSearch.new
      # Number of features
      size = dataset.first.length
      # Number of mutations
      mutations = (size * 0.1).floor
      # Initial solution
      current_solution = @random.randomSolution(size, seed)
      # Solve with local search
      best_solution = @local.solve_with_solution(dataset, current_solution, first, seed)
      best_value = @classifier.classify(dataset, best_solution, first)

      14.times do |j|
        # Apply mutation
        changed = modify(best_solution, first, mutations, size, seed + j)
        # Local search
        optimized = @local.solve_with_solution(dataset, changed, first, seed + j)
        changed_value = @classifier.classify(dataset, optimized, first)
        # Change best solution if new solution improves.
        if changed_value > best_value
          best_value = changed_value
          best_solution = Array.new(optimized)
        end
      end
      best_solution
    end

  end
end
