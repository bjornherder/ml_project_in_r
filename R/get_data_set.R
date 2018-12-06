library(tidyverse)
library(mlbench)
library(caret)

set.seed(42)

data(BreastCancer)
BreastCancer

# The write_csv in the readr package is more efficient and with uses other formating
BreastCancer %>% readr::write_csv("input/cancer.csv")

# Look at the how the loaded data looks
cancer <- readr::read_csv("input/cancer.csv")
cancer

# Split data
# Split into training (cross-validation) and test set 80-20
# with balanced class distributions within splits

.create_train_test_split <- function(dataset, y = "y"){
  train_index <- createDataPartition(dataset[[y]],
                                     p = .8, 
                                     list = FALSE, 
                                     times = 1)
  return(train_index)
}

train_index <- .create_train_test_split(cancer, y = "Class")

train_split = cancer %>% 
  as.data.frame() %>% 
  .[train_index,] 

train_split  %>%  readr::write_csv(path = "data/train_split.csv")

test_split = cancer %>% 
  as.data.frame() %>% 
  .[-train_index, ]

test_split %>% readr::write_csv(path = "data/test_split.csv")
