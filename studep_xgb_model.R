# Load libraries
library(tidyverse)
library(caret)
library(xgboost)

# Load and clean data
df <- read.csv("C:/Users/gokul/Downloads/student_depression_dataset.csv", stringsAsFactors = FALSE)

# Clean column names
colnames(df) <- gsub("\\.", " ", colnames(df))
colnames(df) <- str_trim(colnames(df))

# Drop ID column
df <- df %>% select(-id)

# Clean Sleep Duration quotes
df$`Sleep Duration` <- gsub("'", "", df$`Sleep Duration`)

# Convert target to numeric
df$Depression <- as.numeric(as.character(df$Depression))

# Convert categorical variables to factors
cat_vars <- c(
  "Gender", "City", "Profession", "Sleep Duration", "Dietary Habits", "Degree",
  "Have you ever had suicidal thoughts", "Family History of Mental Illness"
)

df[cat_vars] <- lapply(df[cat_vars], factor)

# One-hot encode categorical variables
dummies <- dummyVars(Depression ~ ., data = df)
df_encoded <- predict(dummies, newdata = df) %>% as.data.frame()

# Add target back
df_encoded$Depression <- df$Depression

# Split into train and test
set.seed(123)
train_index <- createDataPartition(df_encoded$Depression, p = 0.8, list = FALSE)
train <- df_encoded[train_index, ]
test <- df_encoded[-train_index, ]

# Prepare matrices for xgboost
train_matrix <- xgb.DMatrix(data = as.matrix(train %>% select(-Depression)), label = train$Depression)
test_matrix  <- xgb.DMatrix(data = as.matrix(test %>% select(-Depression)), label = test$Depression)

# Set parameters
params <- list(
  booster = "gbtree",
  objective = "binary:logistic",
  eval_metric = "error",
  eta = 0.03,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.8
)

# Train model
set.seed(123)
xgb_model <- xgb.train(
  params = params,
  data = train_matrix,
  nrounds = 300,
  watchlist = list(train = train_matrix, test = test_matrix),
  verbose = 1,
  early_stopping_rounds = 20
)

# Predict
pred_prob <- predict(xgb_model, test_matrix)
pred <- ifelse(pred_prob > 0.5, 1, 0)

# Evaluate
conf_mat <- confusionMatrix(as.factor(pred), as.factor(test$Depression))
print(conf_mat)
cat("\nModel Accuracy:", round(conf_mat$overall['Accuracy'], 4), "\n")

# Save model
xgb.save(xgb_model, "xgb_studep_model.model")
cat("Model saved to xgb_studep_model.model\n")
