#1. Data understanding ===================================================================================================

#Import data
df <- read.csv("data.csv", sep=";")
head(df)

#Let's visualize the data
options(scipen=999) #Remove scientific notation
ts.plot(df$Sales, col="blue", main="Sales over time", ylab="Amount", xlab="Weeks")
ts.plot(df$Flyer, col="green", main="Flyer spending", ylab="Amount", xlab="Weeks")
ts.plot(df$Adwords, col="red", main="Adwords spending", ylab="Amount", xlab="Weeks")

#2. Data preprocessing ===================================================================================================

#There are high volatility, we'll use log transformations to smoth them
df$LSales <- log(df$Sales+1)
df$LAdwords <- log(df$Adwords+1)
df$LFlyer <- log(df$Flyer+1)
head(df)

#Let's see the results
ts.plot(df$LSales, col="blue", main="Sales over time", ylab="Amount", xlab="Weeks")
ts.plot(df$LFlyer, col="green", main="Flyer spending", ylab="Amount", xlab="Weeks")
ts.plot(df$LAdwords, col="red", main="Adwords spending", ylab="Amount", xlab="Weeks")

#Format as time series
LSales <- ts(df$LSales, frequency=52, start=c(1,1))
LAdwords <- ts(df$LAdwords, frequency=52, start=c(1,1))
LFlyer <- ts(df$LFlyer, frequency=52, start=c(1,1))

#Unit root test for Sales
library(tseries) #Required package
tseries::adf.test(LSales) #We need p<0.05 (lesser) to say the data is stationary
tseries::kpss.test(LSales) #We need p>0.05 (greater) to say the data is stationary
tseries::pp.test(LSales) #We need p<0.05 to (lesser) say the data is stationary
#Sales is stationary (All ok)

#Unit root test for Adwords
tseries::adf.test(LAdwords) #We need p<0.05 (lesser) to say the data is stationary
tseries::kpss.test(LAdwords) #We need p>0.05 (greater) to say the data is stationary
tseries::pp.test(LAdwords) #We need p<0.05 to (lesser) say the data is stationary
#Adwords is evolving (adf and pp failed)

#Unit root test for Flyer
tseries::adf.test(LFlyer) #We need p<0.05 (lesser) to say the data is stationary
tseries::kpss.test(LFlyer) #We need p>0.05 (greater) to say the data is stationary
tseries::pp.test(LFlyer) #We need p<0.05 to (lesser) say the data is stationary
#Flyer is stationary (Only kpss failed)

#We'll correct Adwords by taking the first-difference of the serie
DLAdwords <- diff(LAdwords, differences = 1)
DLAdwords <- c(NA, DLAdwords)
df$DLAdwords <- DLAdwords
head(df)
str(df)

#For tseries::pp.test
DLAdwords_clean <- na.omit(DLAdwords)

#Unit root test for corrected Adwords
tseries::adf.test(DLAdwords) #We need p<0.05 (lesser) to say the data is stationary
tseries::kpss.test(DLAdwords) #We need p>0.05 (greater) to say the data is stationary
tseries::pp.test(DLAdwords_clean) #We need p<0.05 to (lesser) say the data is stationary
#Adwords is evolving (adf and pp failed)
#Now Adwords is stationary too

#Now we'll determine the lags using ACF and PACF plots
library(forecast)
forecast::ggtsdisplay(LSales)
#The plot show a clear cutoff for PACF (AR) and ACF (MA) both in 1 lag
#So for modeling we can build an ARMA(1,1) or ARIMA(1,0,1)
#The 0 in ARIMA is because we didn't take the difference of the sales series

#We'll create a lagged version of Sales and add it to our dataframe
lag_Sales <- df$LSales[1:121]
lag_Sales <- c(NA, lag_Sales) #The 2st lag is NA
df$lag_Sales <- lag_Sales
head(df)
str(df)

#Finally we'll split into train test (80/20) the dataset
train <- df[1:96,]
test <- df[97:122,]
#Note that there isn't data leakage because the log transformation is done row by row

#3. Data modeling ========================================================================================================

#We'll make 3 models: ARIMA, linear and VAR
#For prediction: ARIMA or linear
#For explanation: VAR
#We could predict using VAR, but in this scenario is more suitable for explanation

#3.1 ARIMA and linear regression =========================================================================================

#ARIMA model
arima_model <- forecast::Arima(ts(train$LSales, frequency=52), order=c(1,0,1), seasonal=c(1,0,1))
summary(arima_model)

#Multiple regression model to include exogenous variables
linear_model <- lm(LSales ~ lag_Sales + DLAdwords + LFlyer, data=train)
summary(linear_model)
#Only lag_Sales is statistical significant, but LFlyer almost (p=0.10)

#Prediction using the models
#ARIMA
predict_arima <- predict(arima_model, order=c(1,0,1), data=test, n.ahead=26)
#MLR
predict_lm <- predict(linear_model, test)

#Plotting the results
library(ggplot2)
predictions_df <- data.frame(test$Week, test$LSales, predict_lm, predict_arima$pred)
ggplot(predictions_df, aes(predictions_df$test.Week)) +
  geom_line(aes(y=test.LSales, colour="Actual Sales")) +
  geom_line(aes(y=predict_lm, colour="MLR Predictions")) +
  geom_line(aes(y=predict_arima$pred, colour="ARIMA Predictions")) +
  scale_colour_manual(values=c("Actual Sales"="blue", "MLR Predictions"="red", "ARIMA Predictions"="orange")) +
  theme_minimal() + 
  labs(title="Sales Predictions", x="Weeks", y="Sales")
#Both models look reasonably good

#Comparison of RMSE for both models
rmse_arima <- sqrt(mean((test$LSales - predict_arima$pred)^2))
print(rmse_arima)
rmse_linear <- sqrt(mean((test$LSales - predict_lm)^2))
print(rmse_linear)

#We'll use the ARIMA model to predict 12 weeks ahead
arima_model %>% forecast(h=12) %>% autoplot()

#Predictions reverting the log
forecast_12 <- arima_model %>% forecast(h=12)
forecast_sales <- exp(forecast_12$mean)-1
forecast_sales

#3.2 VAR model ========================================================================================================

#Package required
library(vars)

#First build the dataset
data.ts.dl <- window(cbind(DLAdwords, LFlyer, LSales), start=c(1,2))

#VAR estimation
var_model <- vars::VAR(data.ts.dl, ic="AIC", lag.max=1, type="const", season=4)
summary(var_model)
var_model$varresult

#A better visualization table
library(stargazer)
res <- var_model$varresult
stargazer::stargazer(res$DLAdwords, 
                     res$LFlyer, 
                     res$LSales, 
                     column.labels=c("DLAdwords","LFlyer", "LSales"),
                     type="text",
                     dep.var.labels.include = FALSE)

#Check for residuals' normality and autocorrelation
sales_residuals <- data.frame(residuals(var_model))$LSales
sales_residuals <- ts(sales_residuals, frequency=52, start=c(1,1))
round(mean(sales_residuals), 2)
autoplot(sales_residuals)
#It's ok, the residuals vary randomly around zero

#3.2.1 Relative importance using FEVD =================================================================================

#We'll use FEVD to analyze the relative importance of the variables
importance <- vars::fevd(var_model, n.ahead=7)
round(importance$LSales, 4)
plot(importance)
#The table corresponds to the bottom panel of the graph

#3.2.2 Effects along time using IRF ===================================================================================

#Now we perform the IRF to evaluate the effects along the time
#This is the orthogonalized impulse reaction function, to estimate the GIRF
#we need to estimate a Bayesian VAR model
irfs <- vars::irf(x=var_model, 
                  impulse=c("DLAdwords", "LFlyer"), 
                  response="LSales",
                  runs=100, #Bootstraps
                  n.ahed=7,
                  ortho=TRUE,
                  ci=0.95)
plot(irfs)
#LFlyer: impact sales inmediately, then decrease to 0 in time 6
#DLAdwords: impact sales in time 2, then decrease to 0 in time 6

#We are going to evaluate the significance of each IRF coefficient, we'll
#use the rule t>1 

#Step 1: Make a table to summarize IRF coefficients and their confidence intervals
irf.table.ci <- round(data.frame(period = seq(1, 11), 
                                 response.Adwords = irfs$irf$DLAdwords, 
                                 Adwords.lower = irfs$Lower$DLAdwords, 
                                 Adwords.upper = irfs$Upper$DLAdwords, 
                                 response.flyer = irfs$irf$LFlyer, 
                                 flyer.lower = irfs$Lower$LFlyer, 
                                 flyer.upper = irfs$Upper$LFlyer),4)
colnames(irf.table.ci) <- c('Period', 'DLAdwords', 'DLAdwords Lower', 'DLAdwords Upper','LFlyer', 
                            'LFlyer Lower', 'LFlyer Upper')
library(knitr)
knitr::kable(irf.table.ci)

#Step 2 (Adwords): Now we apply our t>1, where t = beta/standard error, the se is derived from the ci
result_irf_adwords<-matrix(nrow = 8, ncol = 1)

for (i in 1:8) {
  se <- (irfs$Upper$DLAdwords[i]-irfs$Lower$DLAd[i])/(2*1.96)
  t_irf_adwords <- irfs$irf$DLAdwords[i]/se
  
  if (t_irf_adwords>1) {
    result_irf_adwords[i] <- irfs$irf$DLAdwords[i]
  } else {
    result_irf_adwords[i] <-0
  }
}

result_irf_adwords #print out the results
lr_adwords <- sum(result_irf_adwords)
lr_adwords #Total temporal effect of adwords

#Step 2 (Flyer): Now we apply our t>1, where t = beta/standard error, the se is derived from the ci
result_irf_flyers<-matrix(nrow = 8, ncol = 1)

for (i in 1:8) {
  se <- (irfs$Upper$LFlyer[i]-irfs$Lower$LFlyer[i])/(2*1.96)
  t_irf_flyers<- irfs$irf$LFlyer[i]/se
  
  if (t_irf_flyers>1) {
    result_irf_flyers[i] <- irfs$irf$LFlyer[i]
  } else {
    result_irf_flyers[i] <-0
  }
}

result_irf_flyers #print out the results
lr_flyers <- sum(result_irf_flyers)
lr_flyers #Total temporal effect of flyers

#What the IRF tells us?
#Adwords: a 1% increase in adwords growth (we are using differenced values) will increase the sales in 0.03% (0.03663839).
#Flyer: a 1% increase in flyers will increase sales in 0.12% (0.1247173)

#3.2.3 Optimal budget allocation ==========================================================================================

#Current budget allocation
cost_adwords<-sum(df$Adwords)
cost_flyer<-sum(df$Flyer)
cost_total <- cost_adwords + cost_flyer

costshare_adwords<-cost_adwords/cost_total
costshare_flyer<-cost_flyer/cost_total

#Pie chart to see the results
slices_actual<-c(costshare_adwords, costshare_flyer )
lbls_actual<-c("Adwords", "Flyer")
pct_actual<-round(slices_actual*100)
lbls_actual<-paste(lbls_actual, pct_actual) #Add data to labels
lbls_actual<-paste(lbls_actual, "%", sep="") #Add % sign to labels

pie(slices_actual, 
    labels=lbls_actual, 
    col=rainbow(length(lbls_actual)), 
    main="Actual Budget Allocation")

#We'll use the IRF to estimate the optimal allocation of resources
beta_all <- lr_adwords + lr_flyers

#Optimal resource allocation
optim_adwords<-lr_adwords/beta_all
optim_adwords
optim_flyer<-lr_flyers/beta_all
optim_flyer

#Pie chart to see the optimal allocation 
optimal_spend<-c(optim_adwords,optim_flyer)
optimal_spend=round(optimal_spend, digits=5)
optimal_spend

slices_optim<-c(optim_adwords, optim_flyer)
lbls_optim<-c("Adwords", "Flyer")
pct_optim<-round(slices_optim*100)
lbls_optim<-paste(lbls_optim, pct_optim)   # paste variable names to data labels 
lbls_optim<-paste(lbls_optim, "%", sep="") # add % sign to labels

pie(slices_optim, 
    labels=lbls_optim, 
    col=rainbow(length(lbls_optim)), 
    main="Optimal Budget Allocation" )

#The firm should spend more in Adwords, from 15% to 23%, and reduce its spending
#on Flyer, from 85% to 77%. These results assumes that you want to optimize sales,
#but you could optimize for other metrics like market share or profits.