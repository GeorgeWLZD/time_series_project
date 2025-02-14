# Time Series Project

## 1. Business Case

ABC company operates in the telecom industry in an emerging market. The company so far has focused all its marketing efforts on offline **flyer advertising** and online **Google AdWords**. However, recent performance reports showed that ABC’s sales have not been reaching the management’s expectations. The CMO, in preparation for a meeting with the CEO and CFO wants to **answer these questions**:

- Q1: What would be the **forecast of demand** for the next 12 weeks?
- Q2: What are the **drivers of sales** in the long run? What is the **contribution** of each marketing action to sales?
- Q3: To what extent do AdWords and flyers **impact sales** in the short versus long run?
- Q4: How should ABC allocate **marketing budget** between AdWords and flyers to get the best results?

## 2. Data Structure

We have the historical weekly sales and marketing expenditure on flyer advertising and Google AdWords advertising spend over a **time span of 122 weeks**. Here we have a **glimpse of the first 10 rows** of the dataset:

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/ac35cedcf55b8042ab71b85832639cd61c4125ed/img/data.JPG)

## 3. Statistical Analysis

The first step was the **exploration** of the change of variables over time, so we can have a better understanding of what we are dealing with:

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/babef8350c5bbdc92384384b909a2d3ef352a8a7/img/exploration.JPG)

- Q1: What would be the forecast of demand for the next 12 weeks?
To answer this question I develop 2 models, first a linear regression as base model, and then an ARIMA process which was the chosen one because it had the lesser error. Here we have the **comparison of the models**:
![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/5ac648eda21bce679cd2aa7ccd641517a7af416a/img/comparison.png)
The final predictions for **12 weeks ahead** are the following:
![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/8d777768f3fe0d0a5f82808e4208ba1f93b5f4f5/img/arima.png)
- Q2: What are the drivers of sales in the long run? What is the contribution of each marketing action to sales?
- Q3: To what extent do AdWords and flyers impact sales in the short versus long run?
- Q4: How should ABC allocate marketing budget between AdWords and flyers to get the best results?

## 4. Business Recommendation

T

![image alt]()

