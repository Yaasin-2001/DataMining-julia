using CSV
using DataFrames
using LIBSVM
using Random  # For shuffle function

# Load the data
df = CSV.read("dizi_verileri/1975-1999_yilin_diziler.csv", DataFrame)

# Dropping rows with missing values
df = dropmissing(df)

# Excluding 'Dizinin_İsmi' from the features
features = select(df, Not([:Sezon_Sayısı, :Dizinin_İsmi]))
target = df.Sezon_Sayısı

# Convert features DataFrame to Matrix
feature_matrix = Matrix(features)

# Convert target to a vector of Integers (required for LIBSVM)
target_vector = Vector{Int}(target)

# Split the data into training and test sets
train_proportion = 0.7
n = nrow(df)
indices = shuffle(1:n)
train_indices = indices[1:floor(Int, train_proportion * n)]
test_indices = indices[(floor(Int, train_proportion * n) + 1):end]

train_features = feature_matrix[train_indices, :]
train_target = target_vector[train_indices]
test_features = feature_matrix[test_indices, :]
test_target = target_vector[test_indices]

# Training the SVM model
model = svmtrain(train_features', train_target)

# Making predictions and evaluating the model
predicted_labels, decision_values = svmpredict(model, test_features')

# Manually calculate accuracy
correct_predictions = sum(predicted_labels .== test_target)
total_predictions = length(test_target)
accuracy = correct_predictions / total_predictions

println("Accuracy: ", accuracy)