#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'

module FeatureSelection

  class Genetics

    private

    # Returns sorted random pair of integers, between 0 and 'max' (max not included). Uses 'seed' for random seed.
    def randomPair(max, seed)
      r = Random.new(seed)
      first = r.rand(max)
      second = r.rand(max)
      while first == second
        second = r.rand(max)
      end
      [first,second].sort
    end

    public

    def initialize
      @classifier = Classifier.new
      @random = GetRandom.new
    end

    # Elitist generational version
    def solveElitist(dataset, first, seed = 1)
      # Number of features.
      size = dataset.first.length
      iterations = 0
      max_iterations = 2500
      # Population number.
      elements = 30
      # Expected number of crossings and mutations.
      cross = (elements*0.7*0.5).floor
      mutations = (size * elements * 0.001).ceil
      # Creating initial population.
      # Solutions will be a pair [value, solution], to avoid multiple clasifications.
      population = []
      elements.times do |i|
        solution = @random.randomSolution(size, seed + i)
        value = @classifier.classify(dataset, solution, first)
        iterations += 1
        population << [value, solution]
      end
      # Sorting population by value, greatest first.
      population.sort!.reverse!
      # Loop.
      while iterations < max_iterations
        # Saving best solution (elitism).
        best_solution = Array.new(population.first)
        # Crossed generation will have solutions, new generation and new population will have pairs [value, solution].
        new_generation = []
        crossed_generation = []
        new_population = []

        # Tourney (selection operator). Choosing min in a random pair (will be the best solution, as they are ordered).
        elements.times do |i|
          index = randomPair(elements, i+1).min
          new_generation << population[index]
        end

        # Generating new population, crossing.
        cross.times do |i|
          # Getting splitting points, parents.
          splitting = randomPair(size, iterations + i)
          indexes = randomPair(new_generation.length, iterations + i + 1)
          parents = [new_generation[indexes.first], new_generation[indexes.last]]
          # Crossing parents.
          # We get first M elements of the first parent, then get [M,...,N] elements of the second one, and complete with first parent.
          # We do the opposite for the second son.
          # parents.first.last will choose the solution, as parent.first is a [value, solution] element.
          son1 = parents.first.last.first(indexes.first) +
                 parents.last.last.slice(indexes.first..indexes.last) +
                 parents.first.last.slice((indexes.last+1)..size)

          son2 = parents.last.last.first(indexes.first) +
                 parents.first.last.slice(indexes.first..indexes.last) +
                 parents.last.last.slice((indexes.last+1)..size)
          # Add sons to new generation.
          crossed_generation << son1
          crossed_generation << son2
          # Deleting parents. Second index changes, so we delete the correct one.
          # Second index is always greater than first, so we always have to subtract 1 to the second index.
          new_generation.delete_at(indexes.first)
          new_generation.delete_at(indexes.last - 1)
        end
        # Mutation.
        mutations.times do |i|
          # Choosing element and gen to be changed.
          elem = Random.new(iterations + i).rand(crossed_generation.size)
          chosen = crossed_generation[elem]
          gen = Random.new(iterations + i + 1).rand(size)
          # Apply mutation.
          # Ruby uses references to arrays, so changing 'chosen' will change element in 'new_population' selected.
          chosen[gen] = (chosen[gen] - 1).abs
        end
        # Classifing new population, maintaining best of previous one.
        crossed_generation.each do |solution|
          value = @classifier.classify(dataset, solution, first)
          iterations += 1
          new_population << [value, Array.new(solution)]
        end
        # Adding non-used parents.
        new_population.concat(new_generation)
        # If best solution is not maintained, we add it.
        unless new_population.include?(best_solution)
          new_population.pop
          new_population.push(Array.new(best_solution))
        end
        population = Array.new(new_population)
        population.sort!.reverse!
      end
      # Returns best solution.
      population.sort!.reverse!
      population.first.last
    end

    # Stationary version
    def solveStationary(dataset, first, seed = 1)
      # Number of features.
      size = dataset.first.length
      iterations = 0
      max_iterations = 1500
      # Population number.
      elements = 30
      # Expected number of mutations, considering two sons.
      # Will always be < 1. Using it as a probability param.
      mutation = (size * 2 * 0.001)
      # Creating initial population.
      # Solutions will be a pair [value, solution], to avoid multiple clasifications.
      population = []
      elements.times do |i|
        solution = @random.randomSolution(size, seed + i)
        value = @classifier.classify(dataset, solution, first)
        iterations += 1
        population << [value, solution]
      end
      # Sorting by value, reverse to have greatest first.
      population.sort!.reverse!
      # Loop.
      while iterations < max_iterations
        # Getting splitting points and parents.
        splitting = randomPair(size, iterations)
        # Parents: Instead of choosing two pairs and compete, we choose just one pair.
        # Competing is just take the min of the two indexes, generated randomly. We avoid it, it's not really relevant.
        index = randomPair(elements, iterations + 1)
        parents = [population[index.first], population[index.last]]
        # Crossing parents.
        # We get first M elements of the first parent, then get [M,...,N] elements of the second one, and complete with first parent.
        # We do the opposite for the second son.
        son1 = parents.first.last.first(index.first) +
               parents.last.last.slice(index.first..index.last) +
               parents.first.last.slice((index.last+1)..size)

        son2 = parents.last.last.first(index.first) +
               parents.first.last.slice(index.first..index.last) +
               parents.last.last.slice((index.last+1)..size)

        # Mutations. Only if random number < mutation probability.
        if Random.new(iterations).rand < mutation
          # Get son, gen to be changed.
          elem = Random.new(iterations).rand(1)
          chosen = elem == 0 ? son1 : son2
          gen = Random.new(iterations+1).rand(size)
          # Apply mutation.
          # Ruby uses references to arrays, and due to that, changing 'chosen' will also change 'son1' or 'son2'.
          chosen[gen] = (chosen[gen] - 1).abs
        end

        # Classification.
        value1 = @classifier.classify(dataset, son1, first)
        value2 = @classifier.classify(dataset, son2, first)
        iterations += 2
        # Add them to population if value is better than the worst in population.
        # Sorting population by value, in order to keep it always sorted.
        if value1 > population.last.first
          population.pop
          population << [value1, son1]
          population.sort!.reverse!
        end
        if value2 > population.last.first
          population.pop
          population << [value2, son2]
          population.sort!.reverse!
        end
      end
      # Sort population, return best solution.
      population.sort!.reverse!
      population.first.last
    end

    def solve(dataset, first, seed = 1)
      solveElitist(dataset, first, seed)
    end

  end
end
