require 'active_support/core_ext/hash'

module MLHelper
  def addFeaturesAndLabel(earliest_date, latest_date, examples, labels)
    all_games = Game.where("game_date > ? AND game_date < ?", earliest_date, latest_date)

    all_games.each do |game|
      feature = Feature.find_by_game_id(game.id)
      if feature == nil
        feature = Feature.new
        feature.game_id = game.id
        feature.home_team_won = game.home_team_won
        feature.save
      end

      # keep the feature if it doesn't match the regular expression
      feature_set = feature.attributes.keep_if {|key, value| !(key =~ /.*last.*/) }
      
      # Add in individual features
      excluding = ['id','game_id','home_team_won', 'created_at', 'updated_at']
      feature_set = feature.attributes.except(*excluding)
      
      examples << feature_set
      labels << (feature.home_team_won ? 1 : 0)
    end
  end
  
  def rbfAccuracyGivenDataAndParameters(training_labels, training_examples, testing_labels, testing_examples, gamma, c)
    puts "Gamma = #{gamma}, C = #{c}"
    # =============================================================================
    # train svm
    # =============================================================================

    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new

    parameter.svm_type = Libsvm::SvmType::C_SVC
    parameter.nu = 0.5
    parameter.eps = 0.001

    parameter.cache_size = 100

    parameter.gamma = gamma.to_f
    parameter.c = c.to_f

    # Type can be LINEAR, POLY, RBF, SIGMOID
    parameter.kernel_type = Libsvm::KernelType::RBF

    training_examples = training_examples.map {|ary| Libsvm::Node.features(ary) }
    problem.set_examples(training_labels, training_examples)

    puts "\ttraining..."
    model = Libsvm::Model.train(problem, parameter)

    # =============================================================================
    # find estimated error
    # =============================================================================

    puts "\ttesting..."
    hits = 0.0
    misses = 0
    ones = 0
    testing_examples.each_with_index do |testing_example, i|
      test_example = Libsvm::Node.features(testing_example)
      pred = model.predict(test_example)
      if pred == 1
        ones += 1
      end
      if pred == testing_labels[i]
        hits += 1
      else
        misses += 1
      end
    end

    accuracy = hits / (hits + misses)
    puts "\tAccuracy: #{accuracy}"
    puts "\t1s: #{ones}"
    puts "\tTotal examples: #{hits + misses}"
    return accuracy
  end
end