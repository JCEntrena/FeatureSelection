#!/usr/bin/env ruby
#encoding: utf-8

module FeatureSelection

  class Partition
    public

    # Param first for division, as it depends on the file.
    # Divides the dataset into 5 50-50 balanced partitions of itself.
    # Previously, we would have converted the strings (binary attributes, 0 or 1)
    # into float, and normalized all the float values.
    def divide_partition(data, first)
      # Init data
      @raw_data = data

      @data = []
      @raw_data.each do |i|
        @data << i.to_a
      end
      # Data is now a matrix (array of arrays)

      # Converting string to float and normalizing.
      @data = @data.transpose.each do |i|
        # No conversion in WDBC class.
        if i.first.class == String
          if i.first != 'M' && i.first != 'B'
            i.map! {|j| j.to_f}
          end
        else
          # Normalization
          @max = i.max
          @min = i.min
          if @max != @min
            i.map! {|j| (j-@min)/(1.0*@max-@min)}
          end
        end
      end
      @data = @data.transpose

      # Getting 5x2 partitions. Always the same partition, due to seed.
      # Grouping by feature.
      grouped = first ? @data.group_by {|i| i.first} : @data.group_by {|i| i.last}

      # Shuffling and dividing in two parts.
      # We split each feature in two parts, add each one to @temporal component
      @partition = []
      temporal = [[],[]]
      5.times do |j|
        grouped.values.map do |i|
           t = i.shuffle(random: Random.new(j)).each_slice((1 + i.length)/2).to_a
           temporal[0] = temporal[0] + t[0]
           temporal[1] = temporal[1] + t[1]
        end
        # Add and reinit.
        @partition << temporal
        temporal = [[],[]]
      end
      @partition
    end

  end
end
