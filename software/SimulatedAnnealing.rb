#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'

module FeatureSelection

  class SimulatedAnnealing

    def solve(dataset, first, seed = 1)
      @randomnumber = Random.new(seed)
      @random = GetRandom.new
      @classifier = Classifier.new
      # SA params.
      n_features = dataset.first.length
      max_neighbors = 5 * n_features
      max_success = 0.1 * max_neighbors
      # Number of coolings. 1000 max iterations (change if necessary)
      m = 1000.0/max_neighbors
      # Get pseudo-random first solution.
      current_solution = @random.randomSolution(n_features, seed)
      current_value = @classifier.classify(dataset, current_solution, first)
      best_solution = Array.new(current_solution)
      best_value = current_value
      # Set temperatures. Using geometric cooling.
      final_temperature = 0.001
      temperature = final_temperature/(0.9**m)
      # Possible changes (not considering class)
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      # Stop if no successes (in next while).
      stop = false

      while temperature > final_temperature && !stop
        success = 0
        generated = 0
        index = 0
        while success < max_success && generated < max_neighbors
          # Generating new neighbour.
          local_solution = Array.new(current_solution)
          local_solution[changes[index]] = (local_solution[changes[index]] - 1).abs
          value = @classifier.classify(dataset, local_solution, first)
          generated += 1
          # Metropolis condition or better solution
          if value > current_value || (value != current_value && Math.exp((value - current_value)/temperature) >= @randomnumber.rand)
            success += 1
            current_solution = Array.new(local_solution)
            current_value = value
            if current_value > best_value
              best_solution = Array.new(current_solution)
              best_value = current_value
            end
            index = 0
            changes.shuffle!(random: Random.new(seed))
          end
          index = (index + 1)%changes.length
        end
        # We stop if we have 0 successes.
        if success == 0
          stop = true
        end
        # Cooling
        temperature *= 0.9
      end
      puts "Mejor solución: valor: #{best_value}"
      best_solution
    end

  end
end
