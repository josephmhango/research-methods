###############################################################
# 🧠 INTRODUCTION
# This script demonstrates:
#   1. How to load a dataset from CSV
#   2. How to perform a Chi-square test of independence
#   3. How to perform a Chi-square goodness-of-fit test
#   4. How to perform a two-sample t-test
#   5. How to perform a one-sample t-test
#
# Dataset: iris.csv (150 samples, 3 species of iris flowers)
###############################################################


###############################################################
# 📦 STEP 1: Load data
###############################################################

# If the dataset is not already saved as a CSV, you can create it using:
# write.csv(iris, "iris.csv", row.names = FALSE)

# Read the dataset from a CSV file in your working directory
iris_df <- read.csv("iris.csv")

# View the first few rows
head(iris_df)

# Check structure
str(iris_df)

# Columns:
#   - Sepal.Length, Sepal.Width, Petal.Length, Petal.Width: numeric
#   - Species: categorical (factor)
###############################################################


###############################################################
# 🧮 STEP 2: Chi-square test of independence
###############################################################
# Checks whether two categorical variables are related.

# Create a categorical version of Petal.Length (small vs large)
iris_df$PetalSize <- ifelse(iris_df$Petal.Length > 3, "Large", "Small")
iris_df$PetalSize <- as.factor(iris_df$PetalSize)

# Build contingency table
contingency <- table(iris_df$PetalSize, iris_df$Species)
contingency

# Run Chi-square test of independence
chi_ind <- chisq.test(contingency)
chi_ind

# Interpretation:
#   - H₀: Petal size and species are independent.
#   - H₁: They are associated.
# If p-value < 0.05 → reject H₀ → variables are related.

# View expected counts under H₀
chi_ind$expected
###############################################################


###############################################################
# 📊 STEP 3: Chi-square goodness-of-fit test
###############################################################
# Checks whether observed frequencies differ from a theoretical distribution.

# Example: Are the three species equally common?
species_counts <- table(iris_df$Species)
species_counts

# Expected proportions: equal representation (1/3 each)
expected_proportions <- c(1/10, 1/10, 8/10)

# Run the goodness-of-fit test
chi_gof <- chisq.test(species_counts, p = expected_proportions)
chi_gof

# Interpretation:
#   - H₀: Each species occurs equally often.
#   - H₁: Frequencies differ.
# If p-value > 0.05 → roughly equal representation.
###############################################################


###############################################################
# 📏 STEP 4: Two-sample t-test
###############################################################
# Compares means between two groups of a numeric variable.

# Subset data to two species
iris_two <- subset(iris_df, Species %in% c("setosa", "versicolor"))

# Run independent two-sample t-test
t_two <- t.test(Sepal.Length ~ Species, data = iris_two, var.equal = TRUE)
t_two

# Interpretation:
#   - H₀: Mean Sepal.Length is the same for both species.
#   - H₁: Means differ.
# If p-value < 0.05 → significant difference.

# Visualise the difference
boxplot(Sepal.Length ~ Species, data = iris_two,
        main = "Sepal Length Comparison (Two-sample t-test)",
        ylab = "Sepal Length (cm)",
        col = c("lightblue", "lightgreen"))
###############################################################


###############################################################
# 📏 STEP 5: One-sample t-test (difference from scalar mean)
###############################################################
# Tests whether the mean of one sample differs from a given value.

# Example: Is the mean Sepal.Length of all irises different from 5.5 cm?
mean(iris_df$Sepal.Length)  # observed mean

# Run one-sample t-test
t_one <- t.test(iris_df$Sepal.Length, mu = 5.5)
t_one

# Interpretation:
#   - H₀: The true mean Sepal.Length = 5.5 cm
#   - H₁: The true mean ≠ 5.5 cm
# If p-value < 0.05 → reject H₀ → mean is significantly different from 5.5 cm

# You can also visualise with a simple histogram and reference line
hist(iris_df$Sepal.Length, breaks = 15, col = "lightgray",
     main = "Distribution of Sepal Length",
     xlab = "Sepal Length (cm)")
abline(v = 5.5, col = "red", lwd = 2)
text(5.5, 15, "μ = 5.5 (Test Value)", pos = 4, col = "red")
###############################################################


###############################################################
# ✅ SUMMARY
# - Chi-square (Independence): relationship between two categorical variables
# - Chi-square (Goodness-of-fit): one categorical variable vs expected distribution
# - Two-sample t-test: compares means between two groups
# - One-sample t-test: compares sample mean against a fixed scalar mean
###############################################################
