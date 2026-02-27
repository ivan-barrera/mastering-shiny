library(shiny)
library(vroom)
library(tidyverse)

dir.create("neiss")
download <- function(name) {
  url <- "https://raw.github.com/hadley/mastering-shiny/main/neiss/"
  download.file(paste0(url,name), paste0("neiss/", name), quiet = TRUE)
}

download("injuries.tsv.gz")
download("population.tsv")
download("products.tsv")

injuries <- vroom::vroom("neiss/injuries.tsv.gz")

products <- vroom::vroom("neiss/products.tsv")

population <- vroom::vroom("neiss/population.tsv")

selected <- injuries |> filter(prod_code == 649)
nrow(selected)

selected |> count(location, wt = weight, sort = TRUE)

selected |> count(body_part, wt = weight, sort = TRUE)

selected |> count(diag, wt = weight, sort = TRUE)

summary <- selected |> count(age, sex, wt = weight)

summary |>
  ggplot(aes(age, n, color = sex)) +
  geom_line() +
  labs(y = "Número estimado de lesiones")

summary <- selected |>
  count(age, sex, wt = weight) |> 
  left_join(population, by = c("age", "sex")) |> 
  mutate(rate = n / population * 1e4)

summary %>% 
  ggplot(aes(age, rate, colour = sex)) + 
  geom_line(na.rm = TRUE) + 
  labs(y = "Injuries per 10,000 people")

selected |> 
  sample_n(10) |> 
  pull(narrative)
