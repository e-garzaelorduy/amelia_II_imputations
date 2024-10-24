# Load necessary libraries
library(arrow)
library(Amelia)

# Define the path to the dataset
dat0_path <- "/Users/erikagarzaelorduy/Documents/CSS/Capstone/Amelia/amelia_imputation/dat0.feather"

# Open the dataset
dat <- read_feather(dat0_path)

# View the structure of the data
# This helps to understand the types of variables (e.g., factors, numeric) and their structure
str(dat)

# Count missing values in each column to see where imputation is needed
missing_data <- colSums(is.na(dat))
print(missing_data)

# View a summary of the data for a more detailed overview of the dataset
summary(dat)

# -------------------------------------------------------------
# First Attempt: Treat 'lcat_demog_state' as a Nominal Variable
# Initially, we classified 'lcat_demog_state' as a nominal variable. 
# This led to a successful imputation, but it took a long time because nominal variables with many categories 
# (in this case, representing U.S. states) are computationally expensive for Amelia II.

# Specify nominal and ordinal variables (including 'lcat_demog_state' as nominal in this first attempt)
nominals <- c("cat_demog_region", "dum_demog_female", "cat_demog_marstatus", 
              "cat_demog_race", "dum_vote_trump", "dum_things_going_right", "lcat_demog_state")

ordinals <- c("ocat_demog_educ", "olcat_demog_fam_income", "ocat_hopeful_country", "ocat_approval_congress",
              "ocat_approval_pres", "ocat_seven_point_libcon", "ocat_vote_duty_choice", 
              "ocat_big_state_scale", "ocat_defense_spend_scale", "ocat_hi_publ_priv_scale", 
              "ocat_env_reg_scale", "ocat_aidpoor_budget_shd", "ocat_env_budget_shd", 
              "ocat_importance_checks", "ocat_pol_violence", "ocat_self_censor", "cat_attent_pol", "ocat_how_often_ppl_trust")

# Run Amelia II with 'lcat_demog_state' as a nominal variable
amelia_fit_nominal <- amelia(dat, m = 5, noms = nominals, ords = ordinals)

# While this worked, it generated two warnings: one due to the large number of categories in 'lcat_demog_state', 
# and another about multicollinearity, indicating potential issues with highly correlated variables.
# These issues resulted in a longer runtime and suggest that the quality of the imputation was impacted.

# -------------------------------------------------------------
# Second Attempt: Treat 'lcat_demog_state' as a Numeric Variable
# We reclassified 'lcat_demog_state' as a numeric variable to optimize the imputation process.
# Treating it as numeric significantly reduced the computation time, as Amelia handles continuous variables more efficiently.

# Note: It's unclear if treating a categorical variable like 'lcat_demog_state' (U.S. states) as numeric will impact the validity
# of the imputation. While it speeds up the process, this should be assessed carefully based on the analysis requirements.

# Re-specify the nominal and ordinal variables (excluding 'lcat_demog_state' from the nominal list)
nominals <- c("cat_demog_region", "dum_demog_female", "cat_demog_marstatus", 
              "cat_demog_race", "dum_vote_trump", "dum_things_going_right")

# Convert 'lcat_demog_state' to numeric for better performance
dat$lcat_demog_state <- as.numeric(dat$lcat_demog_state)

# Verify that 'lcat_demog_state' has been successfully converted to numeric
str(dat)

# Run Amelia II again, this time with 'lcat_demog_state' treated as a numeric variable
amelia_fit_numeric <- amelia(dat, m = 5, noms = nominals, ords = ordinals)

# Verifying Imputation: Check if any missing values remain after imputation
# This loop iterates over each of the 5 imputed datasets and confirms that all missing values have been imputed
for (i in 1:5) {
  missing_data_after <- colSums(is.na(amelia_fit_numeric$imputations[[i]]))
  cat("Imputed Dataset", i, ":", "Missing Values:\n")
  print(missing_data_after)
}

# sessionInfo()
# R version 4.4.1 (2024-06-14)
# Platform: aarch64-apple-darwin20
# Running under: macOS Sonoma 14.6.1
# 
# Matrix products: default
# BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
# LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
# 
# locale:
#   [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
# 
# time zone: America/Los_Angeles
# tzcode source: internal
# 
# attached base packages:
#   [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#   [1] Amelia_1.8.2   Rcpp_1.0.13    arrow_17.0.0.1
# 
# loaded via a namespace (and not attached):
#   [1] assertthat_0.2.1  R6_2.5.1          bit_4.5.0         tidyselect_1.2.1  magrittr_2.0.3    glue_1.8.0        foreign_0.8-87   
# [8] bit64_4.5.2       lifecycle_1.0.4   cli_3.6.3         vctrs_0.6.5       compiler_4.4.1    purrr_1.0.2       rstudioapi_0.16.0
# [15] tools_4.4.1       rlang_1.1.4      
# > 