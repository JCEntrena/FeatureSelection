#!/usr/bin/env ruby
#encoding: utf-8
require 'weka'
require_relative 'PartitionSelector.rb'
require_relative 'Classifier.rb'
require_relative 'SFS.rb'
require_relative 'LocalSearch.rb'
require_relative 'TabuSearch.rb'
require_relative 'SimulatedAnnealing.rb'
require_relative 'MultiLocalSearch.rb'
require_relative 'ILS.rb'
require_relative 'GRASP.rb'
require_relative 'Genetics.rb'
require_relative 'Memetics.rb'

module FeatureSelection

  class Selector
    include Singleton
    public

    # Reading data from three files and getting partitions.
    def readerMethod
      reader = Partition.new

      @wdbc = reader.divide_partition(Weka::Core::Instances.from_arff('Dataset/wdbc.arff'), true)
      @libras = reader.divide_partition(Weka::Core::Instances.from_arff('Dataset/movement_libras.arff'), false)
      @arrhythmia = reader.divide_partition(Weka::Core::Instances.from_arff('Dataset/arrhythmia.arff'), false)
    end

    # Solver for KNN.
    def kNNSolver
      @classifier = Classifier.new
      # Getting number of features.
      wdbc_features = @wdbc.first.first.first.size
      libras_features = @libras.first.first.first.size
      arr_features = @arrhythmia.first.first.first.size
      # Creating arrays for clasification.
      array1 = Array.new(wdbc_features, 1)
      array2 = Array.new(libras_features, 1)
      array3 = Array.new(arr_features, 1)

      puts "Clasificación de wdbc."
      @wdbc.each_with_index do |set, index|
        puts "Clasificación de la partición #{index}-1"
        time = Time.now
        ratio = @classifier.classify(set.first, array1, true)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
        puts "Clasificación de la partición #{index}-2"
        time = Time.now
        ratio = @classifier.classify(set.last, array1, true)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
      end

      puts "\nClasificación de libras."
      @libras.each_with_index do |set, index|
        puts "Clasificación de la partición #{index}-1"
        time = Time.now
        ratio = @classifier.classify(set.first, array2, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
        puts "Clasificación de la partición #{index}-2"
        time = Time.now
        ratio = @classifier.classify(set.last, array2, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
      end

      puts "\nClasificación de arrhythmia."
      @arrhythmia.each_with_index do |set, index|
        puts "Clasificación de la partición #{index}-1"
        time = Time.now
        ratio = @classifier.classify(set.first, array3, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
        puts "Clasificación de la partición #{index}-2"
        time = Time.now
        ratio = @classifier.classify(set.last, array3, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio}"
      end

    end

    # Solver for LocalSearch
    def cSolver(clase)
      classifier = Classifier.new

      wdbc_size = @wdbc.first.first.first.size
      libras_size = @libras.first.first.first.size
      arr_size = @arrhythmia.first.first.first.size

      instance = clase.new

      puts "Clasificación de wdbc en #{clase.name}."
      @wdbc.each_with_index do |set, index|
        puts "Clasificación: Aprendizaje: #{index}-1, Test: #{index}-2"
        time = Time.now
        array = instance.solve(set.first, true)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.last, array, true)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"

        puts "Clasificación: Aprendizaje: #{index}-2, Test: #{index}-1"
        time = Time.now
        array = instance.solve(set.last, true)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.first, array, true)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"
      end

      puts "\nClasificación de libras en #{clase.name}."
      @libras.each_with_index do |set, index|
        puts "Clasificación: Aprendizaje: #{index}-1, Test: #{index}-2"
        time = Time.now
        array = instance.solve(set.first, false)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.last, array, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"

        puts "Clasificación: Aprendizaje: #{index}-2, Test: #{index}-1"
        time = Time.now
        array = instance.solve(set.last, false)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.first, array, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"
      end

      puts "\nClasificación de arrhythmia en #{clase.name}."
      @arrhythmia.each_with_index do |set, index|
        puts "Clasificación: Aprendizaje: #{index}-1, Test: #{index}-2"
        time = Time.now
        array = instance.solve(set.first, false)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.last, array, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"

        puts "Clasificación: Aprendizaje: #{index}-2, Test: #{index}-1"
        time = Time.now
        array = instance.solve(set.last, false)
        reduction = array.count(0).to_f/array.length
        ratio = classifier.classify(set.first, array, false)
        puts "Resultados: Tiempo: #{Time.now - time} \nPorcentaje de clasificación: #{ratio} \nReducción: #{reduction}"
      end
    end

    def main
      readerMethod
      #kNNSolver
      cSolver(Memetics)

    end
  end

  if __FILE__ == $0
    Selector.instance.main
  end

end
