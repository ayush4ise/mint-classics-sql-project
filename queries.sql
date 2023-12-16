/* Query1- To find total stock for each warehouse*/ 
SELECT warehouseCode, SUM(quantityInStock) 
FROM products 
GROUP BY warehouseCode; 

/* Query2- To find net profit for each warehouse*/
SELECT  
p.warehouseCode, 
SUM((o.priceEach - p.buyPrice)*o.quantityOrdered) as netProfit
FROM products as p
JOIN orderdetails as o on p.productCode = o.productCode
GROUP BY p.warehouseCode
ORDER BY netProfit DESC; 

/* Query3- To find available capacity for each warehouse*/
SELECT 
p.warehouseCode,  
SUM(p.quantityInStock) AS totalStock,
ROUND(SUM(p.quantityInStock)*100/w.warehousePctCap,0) - SUM(p.quantityInStock) as availableCapacity
FROM products p
JOIN warehouses w ON w.warehouseCode = p.warehouseCode
GROUP BY warehouseCode;

/* Query4- To find unique shipping status */
SELECT DISTINCT(status) FROM orders;

/* Query5- To find the ratio of stock to sales for each product */
SELECT
p.productCode,
ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) AS stockbysalesRatio
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
WHERE o.status IN('Shipped', 'Resolved')
GROUP BY 
productCode, quantityInStock;

/* Query6- Identifying the well-stocked, understocked and overstocked products */
SELECT
p.productCode,
p.warehouseCode,
p.quantityInStock, 
SUM(od.quantityOrdered) AS totalOrdered,
ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) AS stockbysalesRatio,
CASE 
       WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) > 3 THEN 'Overstocked'
       WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) < 0.7 THEN 'Understocked'
       ELSE 'Well-Stocked'
         END AS inventoryStatus
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
WHERE o.status IN('Shipped', 'Resolved')
GROUP BY 
productCode, quantityInStock
ORDER BY
warehouseCode, stockbysalesRatio DESC;

/* Query7- To find out the product with fewer sales which happens to be zero sales */
SELECT 
p.productCode, 
p.productName, 
p.quantityInStock,
SUM(od.quantityOrdered) as totalOrdered 
FROM products p 
LEFT JOIN orderdetails od ON p.productCode = od.productCode 
GROUP BY productCode 
ORDER BY totalOrdered 

/* Query8- To find overstocked and understocked products */
WITH inventorytable AS (
	SELECT
	p.productCode,
	p.warehouseCode,
	p.quantityInStock, 
	SUM(od.quantityOrdered) AS totalOrdered,
	ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) AS stockbysalesRatio,
	CASE 
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) > 3 THEN 'Overstocked'
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) < 0.7 THEN 'Understocked'
		   ELSE 'Well-Stocked'
			 END AS inventoryStatus
	FROM products p
	JOIN orderdetails od ON p.productCode = od.productCode
	JOIN orders o ON od.orderNumber = o.orderNumber
	WHERE o.status IN('Shipped', 'Resolved')
	GROUP BY 
	productCode, quantityInStock
	ORDER BY
	warehouseCode, stockbysalesRatio DESC
)
SELECT
productCode, warehouseCode
FROM inventorytable
WHERE inventoryStatus = 'Overstocked'
ORDER BY warehouseCode;

/* Query9- To find top 10 profitable items */
WITH inventorytable AS (
	SELECT
	p.productCode,
	p.warehouseCode,
	p.quantityInStock, 
	SUM(od.quantityOrdered) AS totalOrdered,
	ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) AS stockbysalesRatio,
	CASE 
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) > 3 THEN 'Overstocked'
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) < 0.7 THEN 'Understocked'
		   ELSE 'Well-Stocked'
			 END AS inventoryStatus
	FROM products p
	JOIN orderdetails od ON p.productCode = od.productCode
	JOIN orders o ON od.orderNumber = o.orderNumber
	WHERE o.status IN('Shipped', 'Resolved')
	GROUP BY 
	productCode, quantityInStock
	ORDER BY
	warehouseCode, stockbysalesRatio DESC
)
SELECT i.productCode,  SUM((o.priceEach - p.buyPrice)*o.quantityOrdered) as netProfit
FROM inventorytable as i
JOIN orderdetails as o on i.productCode = o.productCode
JOIN products as p on p.productCode = i.productCode
GROUP BY o.productCode
ORDER BY netProfit DESC
LIMIT 10;

/* Query10- To find top 10 ordered items */
WITH inventorytable AS (
	SELECT
	p.productCode,
	p.warehouseCode,
	p.quantityInStock, 
	SUM(od.quantityOrdered) AS totalOrdered,
	ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) AS stockbysalesRatio,
	CASE 
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) > 3 THEN 'Overstocked'
		   WHEN ROUND(p.quantityInStock / SUM(od.quantityOrdered), 2) < 0.7 THEN 'Understocked'
		   ELSE 'Well-Stocked'
			 END AS inventoryStatus
	FROM products p
	JOIN orderdetails od ON p.productCode = od.productCode
	JOIN orders o ON od.orderNumber = o.orderNumber
	WHERE o.status IN('Shipped', 'Resolved')
	GROUP BY 
	productCode, quantityInStock
	ORDER BY
	warehouseCode, stockbysalesRatio DESC
)
SELECT productCode,  totalOrdered
FROM inventorytable
ORDER BY totalOrdered DESC
LIMIT 10;