#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'

module FeatureSelection

  class TabuSearch

    def solve(dataset, first, seed = 1)
      @random = GetRandom.new
      @classifier = Classifier.new
      n_features = dataset.first.length
      # Get pseudo-random first solution.
      current_solution = @random.randomSolution(n_features, seed)
      current_value = @classifier.classify(dataset, current_solution, first)

      best_solution = Array.new(current_solution)
      best_value = current_value
      # Possible changes (not considering class)
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      tabu_list = Array.new(n_features/3, -1)

      # 40 * 30 iterations. Change if necessary. 
      40.times do |n|
        best_neighbour_index = -1
        best_neighbour_value = -1
        tabu_move = false
        entorno = changes.shuffle!(random: Random.new(seed * n)).first(30)
        # Getting best move.
        entorno.each do |i|
          local_solution = Array.new(current_solution)
          # Changes the value specified by i.
          local_solution[i] = (local_solution[i] - 1).abs
          value = @classifier.classify(dataset, local_solution, first)
          if value > best_neighbour_value
            if !tabu_list.include?(i)
              tabu_move = false
              best_neighbour_index = i
              best_neighbour_value = value
            elsif value > best_value
              tabu_move = true
              best_neighbour_index = i
              best_neighbour_value = value
            end
          end
        end
        # Changing best move position. If it's the best we've had, we change best solution.
        if best_neighbour_index != -1
          current_solution[best_neighbour_index] = (current_solution[best_neighbour_index] - 1).abs
        end
        if best_neighbour_value > best_value
          best_solution = Array.new(current_solution)
          best_value = best_neighbour_value
        end
        # Adding new tabu move. It depends on whether next move is tabu or not.
        if tabu_move
          tabu_list.delete(best_neighbour_index)
        else
          tabu_list.shift
        end
        tabu_list.push(best_neighbour_index)
      end
      best_solution
    end

  end
end
