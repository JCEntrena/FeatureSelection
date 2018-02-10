#!/usr/bin/env ruby
#encoding: utf-8

require 'weka'

module FeatureSelection

  class Classifier

    public
    # Uses KNN and gives back success rate.
    # First param indicates where the class is.
    def classify(set, binary_vector, first)
      correct = 0.0
      set.each_with_index do |element, i|
        true_class = first ? element.first : element.last
        clase = kNN(i, set, binary_vector, 3, first)
        if clase == true_class
          correct = correct + 1
        end
      end
      # Return success rate.
      correct / set.length
    end

    # KNN with leave-one-out
    def kNN(index, set, binary_vector, k, first)
      calculated_distances = []
      # Storing three smallest distances, comparing in calculating distance loop.
      shortest_distances = Array.new(k, Float::INFINITY)
      size = set.length
      n_features = set.first.length
      # Class position
      class_pos = first ? 0 : n_features-1
      # Arrays for iterating: Elements for leave-one-out elements, features to avoid comparing class.
      elements = (0...size).to_a
      elements.delete(index)
      features = (0...n_features).to_a
      features.delete(class_pos)
      # Distance to another element in the set.
      distance = 0.0
      # Loop: Calculating distance to another element.
      elements.each do |i|
        features.each do |j|
          # We only consider activated features.
          next if binary_vector[j] == 0
          distance += (set[i][j] - set[index][j])**2
          # Break if distance is greater than third smaller distance (never gonna be in 3-NN)
          break if distance > shortest_distances.last
        end
        # If we don't break, add to calculated distances, add new distance to array.
        if distance <= shortest_distances.last
          shortest_distances.pop
          shortest_distances.push(distance)
          shortest_distances.sort!
          calculated_distances << [distance, set[i]]
        end
        # Distance equal to 0 for the next element.
        distance = 0.0
      end
      # Getting classes of first k calculated distances, sorting by first element by default (in this case, distance)
      # Map will get the class. It depends whether the class is the first or last feature, controlled by variable "first"
      classes = calculated_distances.sort.first(k).map {|i| first ? i.last.first : i.last.last}

      # We count repetitions, return most repeated.
      # Thanks, StackOveflow.
      counted = classes.uniq.group_by {|i| classes.count(i)}.max.last
      counted.first
    end

  end
end
