using CSV
using DataFrames
using DecisionTree
using Random  # For shuffle function

# Load the data
df = CSV.read("dizi_verileri/2019_yilin_diziler.csv", DataFrame)

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

println("Accuracy: ", accuracy)