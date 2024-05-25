-- Saurabh Girpunje -- SQL Project Solution File

use orders;

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  
both first name and last name are in upper case, customer_email,  customer_creation_year
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
[Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date, 
no permanent change in the table is required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation. 
A new column name can be used as an alias for your manipulation in case if you are going to
use a CASE statement.) 
*/

## Answer 1.
SELECT 
    oc.CUSTOMER_ID,
    CONCAT(IF(oc.CUSTOMER_GENDER = 'M',
                'MR. ',
                'MS. '),
            UPPER(oc.CUSTOMER_FNAME),
            ' ',
            UPPER(oc.CUSTOMER_LNAME)) AS CUSTOMER_FULLNAME,
    oc.CUSTOMER_EMAIL,
    YEAR(oc.CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE
        WHEN YEAR(oc.CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
        WHEN
            YEAR(oc.CUSTOMER_CREATION_DATE) >= 2005
                AND YEAR(CUSTOMER_CREATION_DATE) < 2011
        THEN
            'B'
        WHEN YEAR(oc.CUSTOMER_CREATION_DATE) >= 2011 THEN 'C'
    END AS CUSTOMER_CATEGORY
FROM
    ONLINE_CUSTOMER oc;


/* Q2. Write a query to display the following information for the products which have 
not been sold: product_id, product_desc, product_quantity_avail, product_price,
inventory values (product_quantity_avail * product_price), 
New_Price after applying discount as per below criteria. 
Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use 
 a CASE statement.)
*/
## Answer 2.
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    p.PRODUCT_PRICE,
    (p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUES,
    CASE
        WHEN p.PRODUCT_PRICE > 200000 THEN (p.PRODUCT_PRICE * 0.8)
        WHEN p.PRODUCT_PRICE > 100000 THEN (p.PRODUCT_PRICE * 0.85)
        WHEN p.PRODUCT_PRICE <= 100000 THEN (p.PRODUCT_PRICE * 0.9)
    END AS NEW_PRICE
FROM
    PRODUCT p
        LEFT JOIN
    ORDER_ITEMS ot ON p.PRODUCT_ID = ot.PRODUCT_ID
WHERE
    ot.PRODUCT_ID IS NULL
ORDER BY INVENTORY_VALUES DESC;


/*Q3. Write a query to display Product_class_code, Product_class_desc,
 Count of Product type in each product class, 
 Inventory Value (p.product_quantity_avail*p.product_price). 
 Information should be displayed for only those product_class_code 
 which have more than 1,00,000 Inventory Value.
 Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT 
    pc.PRODUCT_CLASS_CODE,
    pc.PRODUCT_CLASS_DESC,
    COUNT(p.PRODUCT_ID) AS COUNT_PRODUCT_TYPE,
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUES
FROM
    PRODUCT p
        INNER JOIN
    PRODUCT_CLASS pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
GROUP BY pc.PRODUCT_CLASS_CODE
HAVING INVENTORY_VALUES > 100000
ORDER BY INVENTORY_VALUES DESC;


/* Q4. Write a query to display customer_id, full name, customer_email, 
customer_phone and country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT 
    oc.CUSTOMER_ID,
    CONCAT(IF(oc.CUSTOMER_GENDER = 'M',
                'MR. ',
                'MS. '),
            UPPER(oc.CUSTOMER_FNAME),
            ' ',
            UPPER(oc.CUSTOMER_LNAME)) AS CUSTOMER_FULL_NAME,
    oc.CUSTOMER_EMAIL,
    oc.CUSTOMER_PHONE,
    a.COUNTRY
FROM
    ONLINE_CUSTOMER oc
        LEFT JOIN
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE
    oc.CUSTOMER_ID IN (SELECT 
            CUSTOMER_ID
        FROM
            (SELECT 
                CUSTOMER_ID,
                    SUM(ORDER_STATUS = 'SHIPPED') AS SHIPPED_COUNT,
                    SUM(ORDER_STATUS = 'IN PROCESS') AS INP_COUNT,
                    SUM(ORDER_STATUS = 'CANCELLED') AS CAN_COUNT
            FROM
                ORDER_HEADER
            GROUP BY CUSTOMER_ID) v
        WHERE
            v.SHIPPED_COUNT = 0 AND v.INP_COUNT = 0
                AND v.CAN_COUNT > 0);


/* Q5. Write a query to display Shipper name, City to which it is catering, 
num of customer catered by the shipper in the city , 
number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. 
The main intent is to find the number of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT 
    ad.SHIPPER_NAME,
    ad.CITY,
    COUNT(DISTINCT ad.CUSTOMER_ID) AS COUNT_CUSTOMER,
    COUNT(ad.CITY)
FROM
    (SELECT 
        *
    FROM
        (SELECT 
        s.SHIPPER_NAME, OH.ORDER_STATUS, OH.CUSTOMER_ID AS CUSTOMER
    FROM
        SHIPPER s
    LEFT JOIN ORDER_HEADER OH ON s.SHIPPER_ID = OH.SHIPPER_ID
    WHERE
        s.SHIPPER_NAME = 'DHL'
            AND OH.ORDER_STATUS = 'SHIPPED') ab
    LEFT JOIN (SELECT 
        oc.CUSTOMER_ID, a.CITY
    FROM
        ONLINE_CUSTOMER oc
    LEFT JOIN ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID) ac ON ab.CUSTOMER = ac.CUSTOMER_ID) ad
GROUP BY SHIPPER_NAME , CITY;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold 
and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 
b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status
(Low stock, In stock, and Enough stock) that meets both the conditions i.e. on products as well as on quantity
The meaning of the rest of the categories, means products apart from electronics,computers,mobiles and watches
*/

## Answer 6.
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    SUM(oi.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE
        WHEN
            pc.PRODUCT_CLASS_DESC = 'Electronics'
                OR pc.PRODUCT_CLASS_DESC = 'Computer'
        THEN
            CASE
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.1 THEN 'Low inventory, need to add inventory'
                WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.5 THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN
            pc.PRODUCT_CLASS_DESC = 'Mobiles'
                OR pc.PRODUCT_CLASS_DESC = 'Watches'
        THEN
            CASE
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.2 THEN 'Low inventory, need to add inventory'
                WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.6 THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE CASE
            WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
            WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.3 THEN 'Low inventory, need to add inventory'
            WHEN (p.PRODUCT_QUANTITY_AVAIL / SUM(oi.PRODUCT_QUANTITY)) < 0.7 THEN 'Medium inventory, need to add some inventory'
            ELSE 'Sufficient inventory'
        END
    END AS INVENTORY_STATUS
FROM
    PRODUCT p
        LEFT JOIN
    PRODUCT_CLASS pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
        LEFT JOIN
    ORDER_ITEMS oi ON p.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY p.PRODUCT_ID , p.PRODUCT_DESC , p.PRODUCT_QUANTITY_AVAIL
ORDER BY QUANTITY_SOLD DESC;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having
total volume less than the volume of carton id 10
 */

## Answer 7.
SELECT dd.ORDER_ID, dd.VOL_PRODUCT  FROM (
	SELECT *, ROW_NUMBER () OVER (ORDER BY cc.VOL_PRODUCT DESC) AS RANK_KK FROM (
		SELECT *, (bb.LEN * bb.WIDTH * bb.HEIGHT) * bb.PRODUCT_QUANTITY AS VOL_PRODUCT FROM(
			SELECT p.*, ot.ORDER_ID, ot.PRODUCT_QUANTITY FROM PRODUCT p
		LEFT JOIN ORDER_ITEMS ot ON p.PRODUCT_ID = ot.PRODUCT_ID) bb) cc
	WHERE cc.VOL_PRODUCT < (SELECT (c.LEN * c.WIDTH * c.HEIGHT) AS VOL_CARTON FROM CARTON c WHERE c.CARTON_ID = 10)
	ORDER BY cc.VOL_PRODUCT DESC) dd
WHERE RANK_KK = 1;


/*Q8. Write a query to display customer id, customer full name, total quantity and 
total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]*/


## Answer 8.
SELECT 
    bb.CUSTOMER_ID,
    CONCAT(IF(bb.CUSTOMER_GENDER = 'M',
                'MR. ',
                'MS. '),
            UPPER(bb.CUSTOMER_FNAME),
            ' ',
            UPPER(bb.CUSTOMER_LNAME)) AS CUSTOMER_FULLNAME,
    SUM(aa.PRODUCT_QUANTITY),
    SUM((aa.PRODUCT_QUANTITY * aa.PRODUCT_PRICE)) AS TOTAL_VALUE
FROM
    (SELECT 
        oc.CUSTOMER_ID,
            oc.CUSTOMER_FNAME,
            oc.CUSTOMER_LNAME,
            oc.CUSTOMER_GENDER,
            OH.ORDER_ID
    FROM
        ONLINE_CUSTOMER oc
    LEFT JOIN ORDER_HEADER OH ON oc.CUSTOMER_ID = OH.CUSTOMER_ID
    WHERE
        ORDER_STATUS = 'SHIPPED'
            AND PAYMENT_MODE = 'CASH') bb
        LEFT JOIN
    (SELECT 
        OT.ORDER_ID, OT.PRODUCT_QUANTITY, P.PRODUCT_PRICE
    FROM
        ORDER_ITEMS OT
    LEFT JOIN PRODUCT P ON OT.PRODUCT_ID = P.PRODUCT_ID) aa ON bb.ORDER_ID = aa.ORDER_ID
WHERE
    bb.CUSTOMER_LNAME LIKE 'G%'
GROUP BY bb.CUSTOMER_ID;


/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together
 with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 6 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products ,
 product_id’s which are sold with 201 product_id (201 should not be there in output) 
 and are shipped except Bangalore and New Delhi
 */

## Answer 9.
SELECT 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    PRODUCT p
        LEFT JOIN
    ORDER_ITEMS oi ON oi.PRODUCT_ID = p.PRODUCT_ID
        LEFT JOIN
    ORDER_HEADER oh ON oi.ORDER_ID = oh.ORDER_ID
        LEFT JOIN
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
        LEFT JOIN
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE
    oi.ORDER_ID IN (SELECT 
            ORDER_ID
        FROM
            ORDER_ITEMS
        WHERE
            PRODUCT_ID = 201)
        AND a.CITY NOT IN ('BANGALORE' , 'NEW DELHI')
        AND p.PRODUCT_ID <> 201
        AND oh.ORDER_STATUS LIKE '%SHIPPED%'
GROUP BY p.PRODUCT_ID , p.PRODUCT_DESC
ORDER BY TOTAL_QUANTITY DESC;


/* Q10. Write a query to display the order_id, customer_id and customer fullname, total quantity of products 
shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]
 */

## Answer 10.
SELECT 
    oh.ORDER_ID,
    oc.CUSTOMER_ID,
    CONCAT(IF(oc.CUSTOMER_GENDER = 'M',
                'MR. ',
                'MS. '),
            UPPER(oc.CUSTOMER_FNAME),
            ' ',
            UPPER(oc.CUSTOMER_LNAME)) AS CUSTOMER_FULLNAME,
    SUM(ot.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    ORDER_HEADER oh
        LEFT JOIN
    ORDER_ITEMS ot ON oh.ORDER_ID = ot.ORDER_ID
        JOIN
    ONLINE_CUSTOMER oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
        JOIN
    ADDRESS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE
    oh.ORDER_STATUS = 'Shipped'
        AND MOD(oh.ORDER_ID, 2) = 0
        AND a.PINCODE NOT LIKE '5%'
GROUP BY oh.ORDER_ID , oc.CUSTOMER_ID , CUSTOMER_FULLNAME;
