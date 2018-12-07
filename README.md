# ml_project_in_r
Example of how to structure, explore, model and present in a machine learning project using R.

The content in this repository is used to exemplify how a simple project in R can look like and is used together with the material found in the [intro_to_r](https://github.com/bjornherder/intro_to_r) repository.

The example uses the Breast Cancer dataset found in the [_mlbench_](https://cran.r-project.org/web/packages/mlbench/index.html) package.

## Structure

* R 
  * Contains the code for splitting data, exploration and modelling.
* data
  * Used to store the split data sets and summary data of the modelling process.
* input 
  * Used to put raw input data (only applicable for smaller datasets)
* models
  * Used to store model objects 
* Report
  * For the markdown report(s) in the project

## File structure after running modelling script
```
.
├── LICENSE
├── R
│   ├── explore.R
│   ├── get_data_set.R
│   └── model.R
├── README.md
├── data
│   ├── test_split.csv
│   ├── test_summary.csv
│   └── train_split.csv
├── input
│   └── cancer.csv
├── ml_project.Rproj
├── models
│   ├── final_model.RData
│   └── imputation.RData
└── report
    ├── ROC.png
    ├── project_report.Rmd
    └── project_report.html

```

## Related Resources

The [_caret_](http://topepo.github.io/caret/index.html) package

[_Applied Predictive Modeling_](http://appliedpredictivemodeling.com/) by Max Kuhn and Kjell Johnson
