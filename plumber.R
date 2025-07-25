# Generated by the vetiver package; edit with care
library(pins)
library(plumber)
library(rapidoc)
library(vetiver)
library(jsonlite)
library(xgboost)
library(bundle)

b <- board_folder("/data/my-pins")
v <- vetiver_pin_read(b, "DepScan-XGB")

# Initialize log files if they don't exist
if (!file.exists("/tmp/depression_api_logs.txt")) {
  cat("=== Depression API Logs Started ===\n", file = "/tmp/depression_api_logs.txt")
}

if (!file.exists("/tmp/depression_prediction_logs.json")) {
  cat("", file = "/tmp/depression_prediction_logs.json")
}

# Function to interpret depression score
interpret_depression_score <- function(score) {
  if (score < 0.2) {
    return(list(
      level = "Minimal",
      description = "Very low likelihood of depression",
      recommendation = "Maintain current mental health practices"
    ))
  } else if (score < 0.4) {
    return(list(
      level = "Mild", 
      description = "Some signs of stress or mild depression",
      recommendation = "Consider stress management techniques"
    ))
  } else if (score < 0.6) {
    return(list(
      level = "Moderate",
      description = "Moderate depression indicators",
      recommendation = "Consider speaking with a counselor"
    ))
  } else if (score < 0.8) {
    return(list(
      level = "Severe",
      description = "Strong indicators of depression",
      recommendation = "Seek professional mental health support"
    ))
  } else {
    return(list(
      level = "Critical",
      description = "Very high depression risk",
      recommendation = "Seek immediate professional help"
    ))
  }
}

# Function to log prediction data
log_prediction <- function(input_data, output_data, user_agent = "", remote_addr = "") {
    tryCatch({
        # Create detailed log entry with input and output
        log_entry <- list(
            timestamp = as.character(Sys.time()),
            user_agent = user_agent,
            remote_addr = remote_addr,
            input_variables = input_data,
            output_prediction = output_data
        )
        
        # Convert to JSON for structured logging
        log_json <- jsonlite::toJSON(log_entry, auto_unbox = TRUE, pretty = TRUE)
        
        # Console output
        cat("=== DEPRESSION PREDICTION LOG ===\n")
        cat("Timestamp:", log_entry$timestamp, "\n")
        cat("Depression Score:", output_data$depression_score, "\n")
        cat("Level:", output_data$level, "\n")
        cat("=================================\n")
        
        # Append JSON log to file
        cat(log_json, "\n", file = "/tmp/depression_prediction_logs.json", append = TRUE)
        
    }, error = function(e) {
        cat("Error logging prediction:", e$message, "\n")
    })
}

#* @plumber
function(pr) {
  pr %>%
    pr_filter("logger", function(req) {
      log_message <- paste0(
        as.character(Sys.time()), " - ",
        req$REQUEST_METHOD, " ", req$PATH_INFO, " - ",
        req$HTTP_USER_AGENT, " @ ", req$REMOTE_ADDR, "\n"
      )
      cat(log_message)
      
      # Also log to file
      cat(log_message, file = "/tmp/depression_api_logs.txt", append = TRUE)
      
      plumber::forward()
    }) %>%
    pr_post("/predict", function(req, res) {
      tryCatch({
        # Parse JSON input
        raw_input <- jsonlite::fromJSON(req$postBody)
        
        # Convert to data frame
        if (is.list(raw_input) && length(raw_input) > 0) {
          if (is.list(raw_input[[1]])) {
            input_data <- as.data.frame(raw_input[[1]], stringsAsFactors = FALSE)
          } else {
            input_data <- as.data.frame(raw_input, stringsAsFactors = FALSE)
          }
        } else {
          input_data <- as.data.frame(raw_input, stringsAsFactors = FALSE)
        }
        
        # Align with model features
        if (!is.null(v$prototype)) {
          expected_cols <- colnames(v$prototype)
          missing_cols <- setdiff(expected_cols, colnames(input_data))
          
          # Add missing columns with 0
          for (col in missing_cols) {
            input_data[[col]] <- 0
          }
          
          # Reorder columns to match prototype
          input_data <- input_data[, expected_cols, drop = FALSE]
        }
        
        # Convert to matrix
        input_matrix <- as.matrix(input_data)
        
        # Create DMatrix
        dmatrix <- xgb.DMatrix(data = input_matrix)
        
        # Get the raw model and predict
        if (inherits(v$model, "bundled_xgb.Booster")) {
          raw_model <- bundle::unbundle(v$model)
        } else {
          raw_model <- v$model
        }
        
        # Make prediction
        prediction_result <- predict(raw_model, dmatrix)
        
        # Get single depression score
        depression_score <- as.numeric(prediction_result[1])
        
        # Constrain to 0-1 range
        depression_score <- pmax(0, pmin(1, depression_score))
        
        # Get interpretation
        interpretation <- interpret_depression_score(depression_score)
        
        # Format output
        output_data <- list(
          depression_score = round(depression_score, 3),
          percentage = paste0(round(depression_score * 100, 1), "%"),
          level = interpretation$level,
          description = interpretation$description,
          recommendation = interpretation$recommendation
        )
        
        # Log the prediction
        log_prediction(
          input_data, 
          output_data, 
          req$HTTP_USER_AGENT %||% "", 
          req$REMOTE_ADDR %||% ""
        )
        
        return(output_data)
        
      }, error = function(e) {
        res$status <- 400
        list(error = paste("Prediction error:", e$message))
      })
    }) %>%
    vetiver_api(v, endpoints = c("/ping", "/pin-info")) %>%
    
    # Endpoint to view basic API logs
    pr_get("/logs", function(res) {
      if (file.exists("/tmp/depression_api_logs.txt")) {
        res$headers$`Content-Type` <- "text/plain"
        readLines("/tmp/depression_api_logs.txt")
      } else {
        res$status <- 404
        list(error = "API log file not found")
      }
    }) %>%
    
    # Endpoint to view prediction logs (updated to handle empty files)
    pr_get("/prediction-logs", function(res) {
      if (file.exists("/tmp/depression_prediction_logs.json")) {
        res$headers$`Content-Type` <- "application/json"
        log_content <- readLines("/tmp/depression_prediction_logs.json")
        
        # If file is empty, return empty array
        if (length(log_content) == 0 || all(nchar(log_content) == 0)) {
          return("[]")
        }
        
        # Return the log content
        paste(log_content, collapse = "\n")
      } else {
        res$headers$`Content-Type` <- "application/json"
        "[]"
      }
    })
}