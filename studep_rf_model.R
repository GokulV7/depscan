
library(tidyverse)
library(caret)
library(randomForest)

# Load Data
df <- read.csv("C:/Users/gokul/Downloads/student_depression_dataset.csv", stringsAsFactors = TRUE)
summary(df)

df <- df %>% select(-id)

# Convert target to factor
df$Depression <- as.factor(df$Depression)

# Ensure all categorical vars are properly encoded
cat_cols <- sapply(df, is.factor)
df[cat_cols] <- lapply(df[cat_cols], function(x) as.factor(as.character(x)))

# Check for missing values
colSums(is.na(df))

# Splitting the data
set.seed(123)
train_index <- createDataPartition(df$Depression, p = 0.8, list = FALSE)
train <- df[train_index, ]
test <- df[-train_index, ]

# Random Forest Model
set.seed(123)
rf_model <- randomForest(Depression ~ ., data = train,
                         importance = TRUE, ntree = 500)

# Model summary
print(rf_model)

# Predictions
pred <- predict(rf_model, newdata = test)
conf_mat <- confusionMatrix(pred, test$Depression)
print(conf_mat)
accuracy <- conf_mat$overall['Accuracy']
cat("\nModel Accuracy:", round(accuracy, 4), "\n")



