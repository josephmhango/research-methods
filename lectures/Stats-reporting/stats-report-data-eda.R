library(agricolae)
?sweetpotato

data(sweetpotato)
str(sweetpotato)

# what is the question and what is an appropriate analysis?
# Is there an overall effect of virus infection on yield?
# oo = uninfected
# ff = virus f
# cc = virus c
# fc virus f + virus c


boxplot(yield~virus, data = sweetpotato)
sweetpotato$virus <- ordered(sweetpotato$virus, c("oo", "ff", "cc", "fc"))



boxplot(yield~virus, data = sweetpotato)
stripchart(yield~virus, data = sweetpotato,
           vertical = T,
           add = T,
           pch = 16, col = "blue") # vanity

aov1 <- aov(yield~virus, data = sweetpotato)

# Does it fit assumptions of anova?
# Gaussian residuals (distribution of residuals)
hist(residuals(aov1))
shapiro.test(residuals(aov1))

# Homoscedasticity (plot residuals vs fitted vals)
plot(aov1, 1)

# stats results

# overall diff?
anova(aov1)
# anova: df = 3,8, F = 17.3, P = 0.0008

# Which viruses are different to healthy?
# linear model oo to cc: n = 6, t = -0.15, p = 0.012
# linear model oo to fc: n = 6, t = -6.21, p < 0.001
# linear model oo to ff: n = 6, t = -0.15, p = 0.897

data(sweetpotato)
sweetpotato$virus <- relevel(sweetpotato$virus, ref = "oo")
summary(lm(yield~virus, data = sweetpotato))

# all possible comparisons
TukeyHSD(aov1)
# Tukey HSD: oo-ff, diff =  0.6, p = 0.999
# Tukey HSD: oo-cc, diff = 12.5, p = 0.048
# Tukey HSD: oo-fc, diff = 24.0, p = 0.001
# Tukey HSD: ff-cc, diff = 11.9, p = 0.059
# Tukey HSD: ff-fc, diff = 23.5, p = 0.001
# Tukey HSD: cc-fc, diff = 11.5, p = 0.069

