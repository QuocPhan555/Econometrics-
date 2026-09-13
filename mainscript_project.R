getwd()
setwd("C:/Users/ASUS/OneDrive/Advanced Applied Economics/First year/Semester 2/Project in Econometrics")
library(dplyr)
library(readxl)
library(plm)
library(lmtest)
library(sandwich)
library(ggplot2)
library(car)
library(stargazer)
library(fixest)
library(modelsummary)

Health <- read.csv("datain/oced_health expenditure_USD PPP_v1.csv")
GDP <- read.csv("datain/oced_gdp per capita_USD PPP.csv")
Age65 <- read.csv("datain/oecd_percentage of 65+.csv")

Health_clean <- Health %>%
  select(country_short = REF_AREA, 
         country_full = Reference.area,
         year    = TIME_PERIOD,
         health_exp = OBS_VALUE) 
sum(is.na(Health_clean))
         
GDP_clean <- GDP %>%
  filter(PRICE_BASE == "LR")  %>% 
  select(country_short = REF_AREA, 
         country_full = Reference.area,
         year    = TIME_PERIOD,
         GDP_per_capita = OBS_VALUE) 
sum(is.na(GDP_clean))

Age65_clean <- Age65 %>%
  select (country_short = REF_AREA, 
         country_full = Reference.area,
         year    = TIME_PERIOD,
         Share_Age65= OBS_VALUE)
sum(is.na(Age65_clean))

panel <- Health_clean %>%
  inner_join(GDP_clean, by = c("country_short","country_full", "year")) %>%
  inner_join(Age65_clean, by = c("country_short","country_full", "year"))
sum(is.na(panel))


#### Descriptive statistics

summary(panel)

panel %>%
  group_by(year) %>%
  summarise(mean_health = mean(health_exp, na.rm = TRUE)) %>%
  ggplot(aes(x = year, y = mean_health)) +
  geom_line() +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "red") +
  labs(title = "Average Health Expenditure per Capita (2000–2024)",
       x = "Year", y = "USD per capita (PPP)")

  panel %>%
    group_by(country_full) %>%
    summarise(mean_health = mean(health_exp, na.rm = TRUE)) %>%
    arrange(desc(mean_health)) %>%
    ggplot(aes(x = reorder(country_full, mean_health), y = mean_health)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(title = "Average Health Expenditure per Capita by Country",
         x = "", y = "USD per capita (PPP)")

panel %>%
  mutate(post = ifelse(year >= 2020, "Post-COVID", "Pre-COVID")) %>%
  ggplot(aes(x = log(GDP_per_capita), y = log(health_exp), color = post)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm") +
  labs(title = "Log Health Expenditure vs Log GDP per Capita",
       x = "Log GDP per capita", y = "Log Health Expenditure per capita")

####Estimation
panel <- panel %>%
      mutate(
        log_health = log(health_exp),
        log_gdp    = log(GDP_per_capita),
        post       = ifelse(year >= 2020, 1, 0),
        year = as.numeric(as.character(year),
        interaction = log_gdp * post))

panel_plm <- pdata.frame(panel, index = c("country_full", "year"))

#### Baseline two-way FE model (2000-2019)
panel_pre <- panel %>% filter(year <= 2019)
model_pre <- feols(log_health ~ log_gdp +Share_Age65 | country_full + year, 
                   data = panel_pre, cluster = "country_full" )
summary(model_pre)

##### The main model (2000-2024)
model_main <- feols( log_health ~ log_gdp + I(log_gdp * post) + Share_Age65 | country_full + year, 
                     data = panel,cluster = ~ country_full)
summary(model_main)
linearHypothesis(model_main, "log_gdp + I(log_gdp * post) = 0")

##### Robustness - Lagged GDP 

panel_pdata <- pdata.frame(panel, index = c("country_full", "year"))
panel_pdata$log_gdp_lag <- plm::lag(panel_pdata$log_gdp, 1)
panel_lag <- as.data.frame(panel_pdata)
sum(is.na(panel_lag))
model_lag <- feols(  log_health ~ log_gdp_lag + I(log_gdp_lag * post) + Share_Age65   | country_full + year,  data  = panel_lag, cluster = ~ country_full)
summary(model_lag)
linearHypothesis(model_lag, "log_gdp_lag + I(log_gdp_lag * post) = 0")
modelsummary(list("Main" = model_main, "Lagged" = model_lag),stars = TRUE)

##### Robustness - Without Share65Age

model_NoAge65 <- feols(log_health ~ log_gdp | country_full + year, 
                   data = panel, cluster = "country_full" )
summary(model_NoAge65)
coeff_withAge65 <- coef(model_main)["log_gdp"]
coeff_NoAge65 <- coef(model_NoAge65)["log_gdp"]

cbind(c("With Age65"=coeff_withAge65,"Without Age65"=coeff_NoAge65))

##### Robustness - Redefine post period, excluding 2020
panel_ex2020 <- panel %>% filter (year !=2020)
model_ex2020 <- feols( log_health ~ log_gdp + I(log_gdp * post) + Share_Age65 | country_full + year, 
                     data = panel_ex2020,cluster = ~ country_full)
summary(model_ex2020)
linearHypothesis(model_ex2020, "log_gdp + I(log_gdp * post) = 0")


save.image("script/main.RData")


                