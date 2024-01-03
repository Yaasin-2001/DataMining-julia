using CSV
using DataFrames
using DecisionTree
using Random  # For shuffle function

# Initialize an empty array to store accuracies
accuracies = []

# Iterate through each file
for i in 6:24
    # Load the data from the current file
    file_path = "dizi_verileri/$(2000+i)_yilin_diziler.csv"
    df = CSV.read(file_path, DataFrame)

    # Dropping rows with missing values
    df = dropmissing(df)

    # Excluding 'Dizinin_İsmi' from the features
    features = select(df, Not([:Sezon_Sayısı, :Dizinin_İsmi]))
    target = df.Sezon_Sayısı

    # Convert features DataFrame to Matrix
    feature_matrix = Matrix(features)

    # Split the data into training and test sets
    train_proportion = 0.7
    n = nrow(df)
    indices = shuffle(1:n)
    train_indices = indices[1:floor(Int, train_proportion * n)]
    test_indices = indices[(floor(Int, train_proportion * n) + 1):end]

    train_features = feature_matrix[train_indices, :]
    train_target = target[train_indices]
    test_features = feature_matrix[test_indices, :]
    test_target = target[test_indices]

    # Training the Random Forest model
    n_trees = 100  # Number of trees in the forest
    model = RandomForestClassifier(n_trees=n_trees)
    DecisionTree.fit!(model, train_features, train_target)

    # Making predictions and evaluating the model
    predictions = DecisionTree.predict(model, test_features)

    # Manually calculate accuracy
    correct_predictions = sum(predictions .== test_target)
    total_predictions = length(test_target)
    accuracy = correct_predictions / total_predictions

    # Append accuracy to the accuracies array
    push!(accuracies, accuracy)
end

# Display the accuracies for each iteration
println("Accuracies for each iteration: ", accuracies)
