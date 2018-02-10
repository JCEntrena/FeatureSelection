#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'

module FeatureSelection

  class LocalSearch

    def initialize
      # Classifier
      @classifier = Classifier.new
      # For pseudo-random first solution, if necessary.
      @random = GetRandom.new
      # Iterations
      @iterations = 0
    end

    # Used in memetics, to control LS iterations. 
    attr_reader :iterations

    # One iteration of local search, given dataset and solution.
    # To use in memetics algorithm and in local search itself.
    # Returns best solution.
    def iteration(dataset, first, best_solution, best_value, seed)
      solution = Array.new(best_solution)
      # Considering possible changes.
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      changes.shuffle!(random: Random.new(seed * @iterations + 1))
      # Apply each change until one improves classification value.
      changes.each do |i|
        @iterations += 1
        local_solution = Array.new(solution)
        local_solution[i] = (local_solution[i] - 1).abs
        # Classify.
        value = @classifier.classify(dataset, local_solution, first)
        # Comparing.
        if value > best_value
          solution = Array.new(local_solution)
          # Exit each enumerator.
          break
        end
      end
      solution
    end

    # Solving with pseudo-random initial solution.
    def solve(dataset, first, seed = 1)
      # Number of features
      @size = dataset.first.length
      # Get pseudo-random first solution.
      initial_solution = @random.randomSolution(@size, seed)
      # Local search using initial solution.
      best_solution = solve_with_solution(dataset, initial_solution, first, seed)
      # Return best solution
      best_solution
    end

    # Solve with an initial solution given.
    def solve_with_solution(dataset, initial_solution, first, seed = 1)
      # Our initial solution is the best solution so far.
      best_solution = Array.new(initial_solution)
      best_value = @classifier.classify(dataset, best_solution, first)

      # Possible changes (not considering class)
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      continue = true
      @iterations = 0

      while continue
        continue = false
        # One iteration of Local Search.
        new_solution = iteration(dataset, first, best_solution, best_value, seed)
        new_value = @classifier.classify(dataset, new_solution, first)
        # If LS improves, change best solution.
        if new_value > best_value
          best_solution = Array.new(new_solution)
          best_value = new_value
          # Continuing if improvement, and limit has not been reached.
          if (@iterations < 15000)
            continue = true
          end
        end
      end
      best_solution
    end

  end
end
