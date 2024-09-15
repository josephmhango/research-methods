## HEADER ####
## Who: Joseph Mhango
## What: R code supporting ANOVA slides
## Last edited: 2024-09-13
####


## CONTENTS ####
## 01 Set up data in wide and long format
## 02 Conduct an ANOVA with aov and check assumptions
## 03 Conduct post-hoc tests
## 04 ANOVA by hand
## 05 Practice exercises

## 01 Set up data in wide and long format

# Data in "wide format"  ####
A <- c(687, 691, 793, 675, 700, 753, 704, 717)
B <- c(618, 680, 592, 683, 631, 691, 694, 732)
C <- c(618, 687, 763, 747, 687, 737, 731, 603)
D <- c(600, 657, 669, 606, 718, 693, 669, 648)
E <- c(717, 658, 674, 611, 678, 788, 650, 690)

head(chicken.wide <- data.frame(A, B, C, D, E))

# Data in "long format"  ####
# The hard way
weight <- c(A,B,C,D,E)

sire <- c(rep("A", 8),
          rep("B", 8),
          rep("C", 8),
          rep("D", 8),
          rep("E", 8) )

new.long<-(data.frame(sire,weight))

# Flash challenge: change the variable names in new.long

names(new.long) <- c('Sire', 'Weight')

## - Gaussian residuals ####
# Make the model object with aov()

## 02 Conduct an ANOVA with aov and check assumptions
m1 <- aov(formula = Weight ~ Sire, 
          data = new.long)

# Graph to examine Gaussian assumption of residuals
# NB we use rstandard()
par(mfrow = c(1,2))
hist(rstandard(m1),
     main = "Gaussian?")

# Gaussian Check
# Look at residuals with qqPlot()
library(car) # For qqPlot()
qqPlot(x = m1,
       main = "Gaussian?")
par(mfrow=c(1,1))


# Plot for homoscedasticity check
plot(formula = rstandard(m1) ~ fitted(m1),
     ylab = "m1: residuals",
     xlab = "m1: fitted values",
     main = "Spread similar across x?")
abline(h = 0,
       lty = 2, lwd = 2, col = "red")

# Make the mean residual y points (just to check)
y1 <- aggregate(rstandard(m1), by = list(new.long$Sire), FUN = mean)[,2]
# Make the x unique fitted values (just to check)
x1 <- unique(round(fitted(m1), 6))

points(x = x1, y = y1, 
       pch = 16, cex = 1.2, col = "blue")

#Bartlet test
bartlett.test(formula = weight~sire, data = new.long)


## basic boxplot ####

boxplot(Weight ~ Sire, data = new.long,
        ylab = "Weight (g)",
        xlab = "Sire",
        main = "Effect of Sire on 8-wk weight",
        cex = 0) # Get rid of the outlier dot (we will draw it back)

# Make horizontal line for grand mean
abline(h = mean(new.long$Weight), 
       lty = 2, lwd = 2, col = "red") # Mere vanity

# Draw on raw data
set.seed(42)
points(x = jitter(rep(1:5, each = 8), amount = .1),
       y = new.long$Weight,
       pch = 16, cex = .8, col = "blue") # Mere vanity


## 03 Conduct post-hoc tests
summary(m1)
# Use lm() and summary() to generate contrasts
# Use relevel() to set sire C to the reference factor level

# make Sire C the reference level
new.long$Sire <- relevel(as.factor(new.long$Sire), ref="C")

# calculate linear model
m2 <- lm(formula = Weight ~ Sire, 
         data = new.long)

summary(m2)

plot(Weight ~ Sire, 
     data = new.long)

# Bonferroni correction using pairwise t.test

pairwise.t.test(x = new.long$Weight, 
                g = new.long$Sire,
                p.adjust.method = "bonferroni")

#
plot(TukeyHSD(m1))
TukeyHSD(m1)



## Kruskal-Wallis alternative to the 1-way ANOVA

kruskal.test(formula = Weight ~ Sire,
             data = new.long)
# The K-W result is not different to the aov result in this case


## 04 ANOVA by hand

# Calculating ANOVA by hand - let's use the wide chicken dataframe for simplicity

n.groups <- ncol(chicken.wide)
n.per.group <- vector(mode = "integer", length = ncol(chicken.wide))

for(i in 1:ncol(chicken.wide)) {
  n.per.group[i] <- length(chicken.wide[,i])
}

n.individuals <- ncol(chicken.wide)*nrow(chicken.wide)
df.between <- n.groups - 1
df.within <- n.individuals - n.groups
mean.total <- mean(as.matrix(chicken.wide))
mean.per.group <- colMeans(chicken.wide)

ss.between <- sum(n.per.group*(mean.per.group - mean.total)^2)

ss.within <- sum(sum((chicken.wide[,1] - mean.per.group[1])^2),
                 sum((chicken.wide[,2] - mean.per.group[2])^2),
                 sum((chicken.wide[,3] - mean.per.group[3])^2),
                 sum((chicken.wide[,4] - mean.per.group[4])^2),
                 sum((chicken.wide[,5] - mean.per.group[5])^2)
)
ms.between <- ss.between/df.between
ms.within <- ss.within/df.within

# Manual F
(myF <- ms.between/ms.within)

# Anova table
anova(m1)$"F value"[1] # Store-bought F

#######################Exercises###############################


  
  ## 5 Practice exercises
  
  For these exercises, run the code below to recreate the data object `pest`.  There are 40 rows and 2 variables with 2 variables: `damage` and `treatment`.  


pest <- structure(list(damage = c(113.7, 94.4, 103.6, 
                                  106.3, 104, 98.9, 
                                  115.1, 99.1, 120.2, 99.4, 
                                  88, 97.9, 61.1, 72.2, 73.7, 
                                  81.4, 72.2, 48.4, 50.6, 88.2, 
                                  46.9, 32.2, 48.3, 62.1, 69, 
                                  45.7, 47.4, 32.4, 54.6, 43.6, 
                                  104.6, 107, 110.4, 93.9, 105, 
                                  82.8, 92.2, 91.5, 75.9, 100.4), 
                       treatment = c("control", "control", 
                                     "control", "control",
                                     "control", "control", 
                                     "control", "control", 
                                     "control", "control",
                                     "x.half", "x.half", 
                                     "x.half", "x.half", 
                                     "x.half", "x.half", 
                                     "x.half", "x.half", 
                                     "x.half", "x.half", 
                                     "x.full", "x.full", 
                                     "x.full", "x.full",
                                     "x.full", "x.full", 
                                     "x.full", "x.full", 
                                     "x.full", "x.full", 
                                     "organic", "organic", 
                                     "organic", "organic", 
                                     "organic", "organic", 
                                     "organic", "organic", 
                                     "organic", "organic")), 
                  class = "data.frame", 
                  row.names = c(NA, -40L))


<br>
  
  Think of this data as the result of an experiment looking at the effectiveness of pesticide treatment on leaf damage.  Let us imagine that this experiment measured leaf damage (variable "damage" measured in  mm squared) and that the plants were treated with one of 4 treatment levels:
  
  Variable `treatment` with levels

- `control`

- `x.half`

- `x.full`

- `organic` 

The experiment is of course designed to look at an overall effect the various treatments may have to reduce leaf damage relative to the `control.`  In addition, it is of interest to examine the effect of the `organic` treatment compared to that of the `x.half` to the `x.full.`  

The experiment ran using 40 potted plants spaced 1m from each other in a greenhouse setting.  Each treatment was randomly assigned to 10 plants.  Onto each plant was placed 5 red lily beetle (*Lilioceris lilii*) pairs.

<br>
  
  <center>
  
  ![Red lily beetle](img/2.6-red-lily-beetle.jpg)
</center>
  
  <br>
  
  ### 8.1
  
  Make a good, appropriate graph representing the overall experiment.  Show your code. Describe any trends in the data that are apparent from the graph, as well as an initial assessment of principle assumptions of 1-way ANOVA based only on your single graph.


<br>
  
  ### 8.2
  
  Test the assumption of Gaussian residuals for 1-way ANOVA using any graphs or NHST approach that you deem appropriate.  Show your code and briefly describe your EDA findings and conclusion as to whether these data adhere to the Gaussian assumption.


<br>
  
  ### 8.3
  
  Test the assumption of homoscedasticity of residuals for 1-way ANOVA using any graphs or NHST approach that you deem appropriate.  Show your code and briefly describe your EDA findings and conclusion as to whether these data adhere to the homoscedasticity assumption.


<br>
  
  ### 8.4
  
  Perform either a 1-way ANOVA or an appropriate alternative based on your findings in the previous answers.  Show your code, state your results in the technical style and briefly interpret your findings.


<br>
  
  ### 8.5
  
  Perform an appropriate set of *post hoc* tests to compare pairwise mean differences in these data.  Focus on the *post hoc* questions of interest: Is the organic pesticide effective?  Does dose matter in the non-organic treatments?
  
  
  <br>
  
  ### 8.6
  
  Write a plausible practice question involving any aspect of data handling, graphing or analysis for the 1-way ANOVA framework for the iris data (`data(iris)`; `help(iris)`).


<br>
  