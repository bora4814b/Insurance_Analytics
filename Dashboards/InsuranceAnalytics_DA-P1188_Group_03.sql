use insurance_db;
create database insurance_db;
drop database insurance_db;
CREATE TABLE Brokerage (
    client_name              VARCHAR(255),
    policy_number            VARCHAR(100),
    policy_status            VARCHAR(50),
    policy_start_date        DATE,
    policy_end_date          DATE,
    product_group            VARCHAR(100),
    account_exe_id           INT,
    exe_name                 VARCHAR(100),
    branch_name              VARCHAR(100),
    solution_group           VARCHAR(255),
    income_class             VARCHAR(50),
    amount                   DECIMAL(15,2) default null,
    income_due_date          DATE default null,
    revenue_transaction_type VARCHAR(50),
    renewal_status           VARCHAR(50),
    last_updated_date        DATE
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Brokerage_v.csv'
INTO TABLE Brokerage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
 client_name,
 policy_number,
 policy_status,
 @policy_start_date,
 @policy_end_date,
 product_group,
 account_exe_id,
 exe_name,
 branch_name,
 solution_group,
 income_class,
 @amount,
 @income_due_date,
 revenue_transaction_type,
 renewal_status,
 @last_updated_date
)
SET
policy_start_date = NULLIF(NULLIF(@policy_start_date,''),'null'),
policy_end_date   = NULLIF(NULLIF(@policy_end_date,''),'null'),
amount            = NULLIF(NULLIF(@amount,''),'null'),
income_due_date   = NULLIF(NULLIF(@income_due_date,''),'null'),
last_updated_date = NULLIF(NULLIF(@last_updated_date,''),'null');

select * from brokerage;
----------------------------------------------------------------------------------------------------
CREATE TABLE Invoice (
    invoice_number           BIGINT,
    invoice_date             DATE,
    revenue_transaction_type VARCHAR(50),
    branch_name              VARCHAR(100),
    solution_group           VARCHAR(255),
    account_exe_id           INT,
    account_executive        VARCHAR(100),
    income_class             VARCHAR(50),
    client_name              VARCHAR(255),
    policy_number            VARCHAR(100),
    amount                   DECIMAL(15,2),
    income_due_date          DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoices_r.csv'
INTO TABLE Invoice
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from invoice;
----------------------------------------------------------------------------------------------------------
CREATE TABLE Opportunity (
    opportunity_name     VARCHAR(255),
    opportunity_id       VARCHAR(50),
    account_exe_id       INT,
    account_executive    VARCHAR(100),
    premium_amount       DECIMAL(15,2),
    revenue_amount       DECIMAL(15,2),
    closing_date         DATE,
    stage                VARCHAR(100),
    branch               VARCHAR(100),
    specialty            VARCHAR(255),
    product_group        VARCHAR(100),
    product_sub_group    VARCHAR(100),
    risk_details         VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Oppor.csv'
INTO TABLE Opportunity
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-----------------------------------------------------------------------------------------------------------

CREATE TABLE Meeting (
    account_exe_id INT,
    account_executive VARCHAR(255),
    branch_name VARCHAR(255),
    global_attendees VARCHAR(255),
    meeting_date DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Meeting_rn.csv'
INTO TABLE Meeting
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

----------------------------------------------------------------------------------------------------------------
CREATE TABLE Fees (
    client_name VARCHAR(255),
    branch_name VARCHAR(255),
    solution_group VARCHAR(255),
    account_exe_id INT,
    account_executive VARCHAR(255),
    income_class VARCHAR(100),
    amount DECIMAL(15,2),
    income_due_date DATE,
    revenue_transaction_type VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Fees_rn.csv'
INTO TABLE Fees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
---------------------------------------------------------------------------------------------------------------
CREATE TABLE Individual_Budget (
    branch VARCHAR(255),
    account_exe_id INT,
    employee_name VARCHAR(255),
    new_role2 VARCHAR(255),
    new_budget DECIMAL(15,2),
    cross_sell_budget DECIMAL(15,2),
    renewal_budget DECIMAL(15,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/IndividualBudgets_rn.csv'
INTO TABLE Individual_Budget
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

----------------------------------------------------------------------------------------------------------------------

select * from brokerage;
select * from fees;
select * from invoice;
select * from meeting;
select * from Individual_Budget;
select * from opportunity;

----------------------------------------------------------------------------------------------------------------------
 ####Total Target Revenue Amount for New, Cross Sell and Renewal

-- Target Revenue Amount for "Cross Sell" income class
SELECT 'cross_sell' AS income_class, 
CONCAT(ROUND(SUM(cross_sell_budget)/1000000, 2), ' M') AS target_amount 
FROM individual_budget

UNION ALL

-- Target Revenue Amount for "New" income class
SELECT 'new' AS income_class,
CONCAT(ROUND(SUM(new_budget)/1000000, 2), ' M') AS target_amount 
FROM individual_budget

UNION ALL

-- Target Revenue Amount for "Renewal" income class
SELECT 'renewal' AS income_class,
CONCAT(ROUND(SUM(renewal_budget)/1000000, 2), ' M') AS target_amount 
FROM individual_budget;

------------------------------------------------------------------------------------------------------------------------------------------

 #### Total amount from brokerage
select income_class, CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') total_amount from brokerage
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class desc;

#### Total amount from fees
select income_class,CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') total_amount from fees
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;
 
#### Total Achieved Revenue Amount for New, Cross Sell and Renewal

SELECT income_class,concat(ROUND(SUM(amount)/1000000, 2), ' M') AS total_achieved_amount
FROM (SELECT income_class, amount FROM brokerage
    UNION ALL
    SELECT income_class, amount FROM fees
) t WHERE income_class IN ('Cross Sell', 'New', 'Renewal') GROUP BY income_class;
 
--------------------------------------------------------------------------------------------------------------------------------------------- 
#### Total invoiced revenue
select income_class, CONCAT(ROUND(SUM(amount)/1000000, 2), ' M') as total_invoiced_amount from invoice
 where income_class in ('Cross Sell','New','Renewal') group by income_class order by income_class;
 
--------------------------------------------------------------------------------------------------------------------------------------
#### Percentage of Placed Achievement for New, Cross Sell and Renewal (achieved_amount/target_amount)
SELECT 

-- Percentage of Placed Achievement for Cross Sell
concat(ROUND(
    (SUM(CASE WHEN income_class = 'Cross Sell' THEN amount ELSE 0 END) /
     (SELECT SUM(cross_sell_budget) FROM individual_budget)) * 100, 2),"%"
) AS cross_sell_placed_achievement,

-- Percentage of Placed Achievement for New 
concat(ROUND(
    (SUM(CASE WHEN income_class = 'New' THEN amount ELSE 0 END) /
     (SELECT SUM(new_budget) FROM individual_budget)) * 100, 2), "%"
) AS new_placed_achievement,

-- Percentage of Placed Achievement for Renewal 
concat(ROUND(
    (SUM(CASE WHEN income_class = 'Renewal' THEN amount ELSE 0 END) /
     (SELECT SUM(renewal_budget) FROM individual_budget)) * 100, 2), "%"
) AS renewal_placed_achievement

FROM (
    SELECT income_class, amount FROM brokerage
    UNION ALL
    SELECT income_class, amount FROM fees
) t;

-----------------------------------------------------------------------------------------------------------------------------------
##### Percentage of Invoiced Achievement for New, Cross Sell and Renewal (invoiced_amount/target_amount)
SELECT 

-- Percentage of Invoiced Achievement for Cross Sell
concat(ROUND(
    (SUM(CASE WHEN income_class = 'Cross Sell' THEN amount ELSE 0 END) /
     (SELECT SUM(cross_sell_budget) FROM individual_budget)) * 100, 2), "%"
) AS cross_sell_invoiced_pct,

-- Percentage of Invoiced Achievement for New
concat(ROUND(
    (SUM(CASE WHEN income_class = 'New' THEN amount ELSE 0 END) /
     (SELECT SUM(new_budget) FROM individual_budget)) * 100, 2), "%"
) AS new_invoiced_pct,

-- Percentage of Invoiced Achievement for Renewal
concat(ROUND(
    (SUM(CASE WHEN income_class = 'Renewal' THEN amount ELSE 0 END) /
     (SELECT SUM(renewal_budget) FROM individual_budget)) * 100, 2), "%"
) AS renewal_invoiced_pct
FROM invoice;

-----------------------------------------------------------------------------------------------------------------
### Year wise Meeting Count
select Meeting_Year,count(*) Meeting_Count
from (
    select year(str_to_date(meeting_date, '%Y-%m-%d')) Meeting_Year
    from meeting) t
group by Meeting_Year
order by Meeting_Year;

----------------------------------------------------------------------------------------------------------------------
###  No of meeting by Account Executive
select account_executive,count(meeting_date) as count_of_meetingdate
 from meeting group by account_executive order by count(meeting_date) desc; 
 
------------------------------------------------------------------------------------------------------------------------
### No. of Invoiced by Account Executive (Total Invoiced and Income_Class wise)
SELECT account_executive,
    SUM(CASE WHEN income_class = 'Cross Sell' THEN 1 ELSE 0 END) AS cross_sell,
    SUM(CASE WHEN income_class = 'New' THEN 1 ELSE 0 END) AS new,
    SUM(CASE WHEN income_class = 'Renewal' THEN 1 ELSE 0 END) AS renewal,
    COUNT(invoice_date) AS total_invoiced
FROM invoice
GROUP BY account_executive
ORDER BY total_invoiced DESC;

-------------------------------------------------------------------------------------------------------------------------------
###  Total opportunities and Open opportunities

-- Total opportunities
select count(stage) as Total_Opportunities from opportunity;

-- Total Open opportunities
select count(stage) as Total_Open_Opportunities from opportunity where stage in ('Propose Solution','Qualify Opportunity');

------------------------------------------------------------------------------------------------------------------------------
### Stage wise Revenue funnel
Select stage, sum(revenue_amount) AS Amount from opportunity Group By stage
ORDER BY amount DESC;

-------------------------------------------------------------------------------------------------------------------------------------
### Top 5 Open-Opportunity by Revenue
select opportunity_name,revenue_amount from opportunity
 where stage IN ('Propose Solution','Qualify Opportunity') order by revenue_amount desc limit 5;

--------------------------------------------------------------------------------------------------------------------------------------
### Opportunity- Product Distribution
select product_group,count(opportunity_name) as Count_of_Opportunity_name 
from opportunity group by product_group order by count(opportunity_name) desc;


