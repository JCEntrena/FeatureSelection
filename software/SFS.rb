#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'Classifier.rb'

module FeatureSelection

  class SFS

    # Receives one partition and calculates best feature selection.
    # 'dataset' is a 50% partition of the full data.
    def solve(dataset, first)
      @classifier = Classifier.new
      # All changes available. We will delete made changes.
      changes = first ? (1..dataset.first.length-1).to_a : (0..dataset.first.length-2).to_a
      # Features already considered (added).
      added = Array.new(dataset.first.length, 0)
      stop = false
      # Best value: 0 at the beginning.
      best_value = 0
      # Loop: Repeat until no improvement
      until stop
        best_index = -1
        copy = Array.new(added)
        # Loop: Check all non-used features, looking for an improvement if considered.
        changes.each do |i|
          copy[i] = 1
          new_value = @classifier.classify(dataset, copy, first)
          # Store index if it improves.
          if new_value > best_value
            best_value = new_value
            best_index = i
          end
          copy[i] = 0
        end
        # If we have an index that improves, best_index != -1
        if best_index != -1
          added[best_index] = 1
          changes.delete(best_index)
        else
          stop = true
        end
      end
      added
    end

  end
end
