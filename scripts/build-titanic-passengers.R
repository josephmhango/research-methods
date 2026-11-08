data("Titanic")

aggregated <- as.data.frame(Titanic)
row_numbers <- rep(seq_len(nrow(aggregated)), aggregated$Freq)

passengers <- aggregated[row_numbers, c("Class", "Sex", "Age", "Survived")]
rownames(passengers) <- NULL

names(passengers) <- c("passenger_class", "sex", "age_group", "survived")
passengers$passenger_id <- seq_len(nrow(passengers))
passengers <- passengers[c("passenger_id", "passenger_class", "sex", "age_group", "survived")]

write.csv(passengers, "data/titanic_passengers.csv", row.names = FALSE)

cat("Created data/titanic_passengers.csv with", nrow(passengers), "passenger rows.\n")
