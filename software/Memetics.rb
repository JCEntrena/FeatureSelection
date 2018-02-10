#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'
require_relative 'Random.rb'

module FeatureSelection

  class Memetics

    private

    def randomPair(max, seed)
      r = Random.new(seed)
      first = r.rand(max)
      second = r.rand(max)
      while first == second
        second = r.rand(max)
      end
      [first,second].sort
    end

    # Local search over all elements
    def hibridation1(dataset, population, local, first, seed)
      new_population = []
      population.each do |i|
        local_sol = local.iteration(dataset, first, i.last, i.first, seed)
        value = @classifier.classify(dataset, local_sol, first)
        @iterations += 1
        new_population << [value, local_sol]
      end
      new_population
    end

    # Local search over randoms element
    def hibridation2(dataset, population, local, first, seed)
      position = Random.new(seed * @iterations + 1).rand(0...10)
      new_population = Array.new(population)
      local_sol = local.iteration(dataset, first, population[position].last, population[position].first, seed)
      value = @classifier.classify(dataset, local_sol, first)
      @iterations += 1
      new_population[position] = [value, local_sol]

      new_population
    end

    # Local search over best element
    def hibridation3(dataset, population, local, first, seed)
      new_population = Array.new(population)
      local_sol = local.iteration(dataset, first, population.first.last, population.first.first, seed)
      value = @classifier.classify(dataset, local_sol, first)
      @iterations += 1
      new_population[0] = [value, local_sol]

      new_population
    end

    public

    def initialize
      @classifier = Classifier.new
      @random = GetRandom.new
    end

    # Using elitist generational version, same as in Genetics.rb, with Local Search.
    # Calling one version of solving: AM(10, 1.0), AM(10, 0.1) and AM(10, Best 0.1)
    def solve(dataset, first, seed = 1)
      solve1(dataset, first, seed)
    end

    # AM(10, 1.0)
    # Applying local search to every element, each 10 iterations.
    def solve1(dataset, first, seed)
      # Create LS object.
      local = LocalSearch.new
      # Problem data.
      count = 0
      size = dataset.first.length
      @iterations = 0
      max_iterations = 5000
      # Population number.
      elements = 10
      # Expected number of crossings and mutations.
      cross = (elements*0.7*0.5).floor
      mutations = (size * elements * 0.001).ceil
      # Creating initial population.
      # Solutions will be a pair [value, solution], to avoid multiple clasifications.
      population = []
      elements.times do |i|
        solution = @random.randomSolution(size, seed + i)
        value = @classifier.classify(dataset, solution, first)
        @iterations += 1
        population << [value, solution]
      end
      # Sorting population by value, greatest first.
      population.sort!.reverse!
      # Loop. Now, adding iterations from genetis to LS iterations.
      while (@iterations + local.iterations < max_iterations)
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
          splitting = randomPair(size, @iterations + i)
          indexes = randomPair(new_generation.length, @iterations + i + 1)
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
          elem = Random.new(@iterations + i).rand(crossed_generation.size)
          chosen = crossed_generation[elem]
          gen = Random.new(@iterations + i + 1).rand(size)
          # Apply mutation.
          # Ruby uses references to arrays, so changing 'chosen' will change element in 'new_population' selected.
          chosen[gen] = (chosen[gen] - 1).abs
        end
        # Classifing new population, maintaining best of previous one.
        crossed_generation.each do |solution|
          value = @classifier.classify(dataset, solution, first)
          @iterations += 1
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

        # Adding 1 to count. Each 10 iterations, we apply LS as specified.
        count += 1

        if count == 10
          count = 0
          # Create new population, apply hibridation. (CHANGE VERSION HERE) 
          new_population = hibridation2(dataset, population, local, first, seed)
          # Sort and reassign.
          new_population.sort!.reverse!
          population = Array.new(new_population)
        end

      end
      # Returns best solution.
      population.sort!.reverse!
      population.first.last
    end


  end
end
