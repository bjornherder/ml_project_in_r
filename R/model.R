library(tidyverse)
library(caret)
library(pROC)

training <- readr::read_csv("data/train_split.csv")

# impute using bagged trees
# preProcess(training, method = c("bagImpute"))
imputation <- preProcess(training, method = c("medianImpute"))

# Result of imputation
training %>% is.na %>% any
training %>% predict.preProcess(imputation, .) %>% is.na %>% any()

# Impute training set
training <- training %>% predict.preProcess(imputation, .)

# Start cluster/ parallel backend
.cores <- parallel::detectCores()
cl <- parallel::makeCluster(.cores - 2 )
doParallel::registerDoParallel(cl)

# Control training
.fitControl <- trainControl(
  method = "repeatedcv",
  selectionFunction = "oneSE",
  classProbs = TRUE,
  number = 5,
  repeats = 5,
  allowParallel = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = 'final')

# Uses non-formula training api as random forest implementation in randomForest package
# can handle factors (does not create dummy variables before training)
non_formula_call <- list()
non_formula_call$x <- training %>% select(-Class) %>% data.frame()
non_formula_call$y <- training[["Class"]]

tune_call <- list()
tune_call$trControl <- .fitControl
tune_call$metric <- "ROC"

rf_call <- list()
rf_call$method <- "rf"
rf_call$tuneGrid <- expand.grid(mtry = seq(2, 4 , by = 1))
rf_call$ntree <- 500

# Function for calling caret training
caret_train <- function(train_call){ do.call(train, train_call) }

res_list <- list()
res_list[["rf"]]  <- c(non_formula_call, rf_call, tune_call) %>% caret_train()

# Stop cluster
parallel::stopCluster(cl)

# Look at ROC curve
# Plot:
plot.roc(res_list[["rf"]]$pred$obs,
         res_list[["rf"]]$pred$malignant)


# Selected model from cross validation
cv_model <- res_list$rf$finalModel

## Performance of selected model on test data

test = readr::read_csv("data/test_split.csv")

test$predicted <- test %>% 
  select(-Class) %>%  
  predict.preProcess(imputation, .) %>% 
  predict(cv_model, .) 

test <- test %>% mutate(tp = if_else((Class == predicted & Class == 'malignant') , 1, 0),
                tn = if_else((Class == predicted & Class == 'benign'), 1, 0),
                fp = if_else((Class != predicted & Class == 'malignant'), 1, 0),
                fn = if_else((Class != predicted & Class == 'benign'), 1, 0))

# Sanity check
c(test$tp, test$tn, test$fp, test$fn) %>% sum()
test %>% nrow

test_summary <- 
  test %>% 
  select(tp, tn, fp, fn) %>% 
  group_by() %>% 
  summarise_all(sum) %>% 
  mutate(accuracy = (tp + tn)/ (tp + tn + fp + fn),
         sensitivity = tp / (tp + fp),
         specificity = tn / (tn + fp),
         f1_score = 2 / (1/sensitivity + 1/specificity),
         number_of_samples = tp + tn + fp + fn)

test_summary
test_summary %>% readr::write_csv("data/test_summary.csv")

## Retrain on all data
all_data <- readr::read_csv(file = "input/cancer.csv")

imputation <- preProcess(all_data, method = c("medianImpute"))
all_data <- all_data %>% 
  predict.preProcess(imputation, .)

.fitControl <- trainControl(method = "none", 
                            classProbs = TRUE,
                            summaryFunction = twoClassSummary,
                            savePredictions = 'final')

final_model <- train(Class ~ ., data = all_data, 
                 method = "rf", 
                 trControl = .fitControl, 
                 verbose = FALSE, 
                 tuneGrid = data.frame(mtry = 2),
                 ntree = 500,
                 metric = "ROC") %>% .$finalModel

save(imputation, final_model, file = "models/final_model.RData")

# (Better) alternative using write_rds
# write_rds(imputation, path = "models/imputation.RData")
# write_rds(final_model, path = "models/final_model.RData")
#
# read_rds("models/imputation.RData")
# read_rds("models/final_model.RData")

# Test loading model
load("models/final_model.RData")
