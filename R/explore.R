library(tidyverse)
library(corrplot)

training <- readr::read_csv("data/train_split.csv")
View(training)

## look at class distribution
training %>%  ggplot(aes(Class, fill = Class)) + 
  geom_bar() + 
  theme_bw() +
  ggtitle('Class distribution in dataset')

## Check for missing values
training %>% is.na() %>% any() # There are missing values in the dataset
training %>% is.na() %>% which() %>% length() # how many missing values

training %>% 
  lapply(is.na) %>% 
  map(any) %>% bind_cols() %>% View # look at which columns have missing values

training %>% 
  group_by() %>% 
  summarise_all(function(x) any(is.na(x))) %>% View# alternative to above

# Remove missing values (or impute depending on reason for missing; MAR, MCAR etc.)
training 

## Look at correlations

# Pearson
training %>% 
  na.omit %>% 
  select(-Id) %>% 
  mutate(Class = if_else(Class == 'malignant', 1L, 0L)) %>% 
  cor(method = "pearson") %>% 
  #(function(x) cor(x = select(x, -Class), y = select(x, Class), method = "pearson")) %>% 
  corrplot()

# Spearman
training %>% 
  na.omit %>% 
  select(-Id) %>% 
  mutate(Class = if_else(Class == 'malignant', 1L, 0L)) %>% 
  cor(method = "spearman") %>% 
  #(function(x) cor(x = select(x, -Class), y = select(x, Class), method = "pearson")) %>% 
  corrplot()

# Distribution of a feature
training %>%
  select(Cell.size) %>% 
  ggplot(aes(Cell.size)) + 
  geom_density(fill='lightblue') +
  theme_bw()

training %>%
  select(Bare.nuclei) %>% 
  ggplot(aes(Bare.nuclei)) + 
  geom_density(fill='lightblue') +
  theme_bw()

# The effect of adding random noise to the point location
training %>% 
  ggplot(aes(Cell.size, Bare.nuclei, color = Class)) + 
  geom_point() +
  theme_bw()

training %>% 
  ggplot(aes(Cell.size, Bare.nuclei, color = Class)) + 
  geom_point(size=1, position = position_jitter()) +
  theme_bw() 
