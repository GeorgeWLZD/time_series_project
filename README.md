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

The final predictions for **12 weeks ahead** are highlighted in blue, and are the following:

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/8d777768f3fe0d0a5f82808e4208ba1f93b5f4f5/img/arima.png)

- Q2: What are the drivers of sales in the long run? What is the contribution of each marketing action to sales?

To determine the drivers I develop a VAR model and evaluate the **Forecast Error Variance Decomposition (FEVD)**. We see that for **sales (LSales)** the lagged values of it have the highest contribution to determine the future sales, and the **offline actions** seems to play a more important role than the **online ads**.

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/bc75a1537d8aa19ed4de7314c27c4b6138b65bc3/img/fevd.JPG)

- Q3: To what extent do AdWords and flyers impact sales in the short versus long run?

For this question the appropriate tool is the **Impulse Response Function (IRF)**. In the plot below we see that increase **flyer (LFlyer)** spending can cause an immediate boost of sales; in contrast, it takes longer time for spending on **AdWords (DLAdwords)** to have positive impact on sales. Moreover, we obsere that these impacts all decay fast and gets close to zero over 6 weeks approximately.

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/804b43e57448e4f6ff45519d2951511c96408d58/img/irf.JPG)

- Q4: How should ABC allocate marketing budget between AdWords and flyers to get the best results?

We can see in the plot below the current budget allocates **85% on flyers** and **15% on Adwords**. Based on the IRF information we can estimate the **optimal allocation**, which is that the firm should actually spend less of its marketing budget on flyer advertising (77%, instead of 85%), and more on AdWords advertising (23% instead of 15%). Contrasting the optimal and actual budget allocation of the firm, it is quite obvious that currently, the firm is **underestimating the power of online marketing** through AdWords and overemphasizing the importance of offline flyers.

![image alt](https://github.com/GeorgeWLZD/time_series_project/blob/9f0687f061fc71e1a0731257f6a2cf1b6fccb25d/img/budget.JPG)

## 4. Business Recommendation

T

![image alt]()

