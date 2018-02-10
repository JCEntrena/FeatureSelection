#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'
require_relative 'LocalSearch.rb'

module FeatureSelection

  class GRASP

    # Generates random greedy solution for GRASP
    def getGreedy(dataset, first, seed)
      @classifier = Classifier.new
      # All changes available. We will delete made changes.
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      # Alpha used
      alpha = 0.3
      # Array of features, all 0 at first.
      added = Array.new(dataset.first.length, 0)
      best_value = 0
      stop = false

      until stop
        candidates = []
        copy = Array.new(added)
        # Loop: Check all non-used features, looking for an improvement if considered.
        changes.each do |i|
          copy[i] = 1
          new_value = @classifier.classify(dataset, copy, first)
          candidates << [new_value, i]
          copy[i] = 0
        end
        # Sort by value.
        candidates.sort!.reverse!
        # Tolerance
        max_value = candidates.first.last
        min_value = candidates.last.last
        mu = max_value - alpha * (max_value - min_value)
        # Getting Restricted List.
        candidates.delete_if {|i| i.last < mu}
        if candidates.length != 0
          # Getting random [value, index]
          element = candidates.shuffle(random: Random.new(seed)).first
          # Apply change
          added[element.last] = 1
          changes.delete(element.last)
          if element.first > best_value
            best_value = element.first
          else
            stop = true
          end
        else
          stop = true
        end
      end
      added
    end

    def solve(dataset, first, seed = 1)

      @classifier = Classifier.new
      @local = LocalSearch.new
      # Initial best.
      best_solution = []
      best_value = -1

      5.times do |j|
        # Get Random Greedy Solution.
        greedy_solution = getGreedy(dataset, first, seed + j)
        # Local Search.
        current_solution = @local.solve_with_solution(dataset, greedy_solution, first, seed)
        value = @classifier.classify(dataset, best_solution, first)
        if value > best_value
          best_solution = Array.new(current_solution)
          best_value = value
        end
      end
      best_solution
    end

  end
end
