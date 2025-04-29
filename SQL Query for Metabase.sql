"Part one: Market Supply and Property Type Analysis"

"Section 1: Detect specific housing types in each area (take 10025 as example)"
SELECT 
    a.zipcode,
    p.type AS housing_type,
    COUNT(p.property_id) AS total_supply
FROM 
    properties p
JOIN 
    addresses a ON p.address_id = a.address_id
WHERE 
    a.zipcode = '10025'
GROUP BY 
    a.zipcode,
    p.type
ORDER BY 
    total_supply DESC;
	
"Section 2: Identify the most popular bedroom-bathroom combinations at different area (take 10025 as example)"
SELECT 
    a.zipcode,
    CONCAT(p.beds, 'b', p.bath, 'b') AS bed_bath_combo,
    COUNT(p.property_id) AS total_listings
FROM 
    properties p
JOIN 
    addresses a ON p.address_id = a.address_id
WHERE 
    a.zipcode = '10025'
GROUP BY 
    a.zipcode,
    bed_bath_combo
ORDER BY 
    total_listings DESC;

"Section 3: Supply Analysis: identify areas with highest listing density"
SELECT 
    a.zipcode,
    COUNT(p.property_id) AS total_listings,
    RANK() OVER (ORDER BY COUNT(p.property_id) DESC) AS listing_rank
FROM 
    properties p
JOIN 
    addresses a ON p.address_id = a.address_id
GROUP BY 
    a.zipcode
ORDER BY 
    total_listings DESC
limit 15;

"Section 4: Supply Analysis: identify areas with lowest listing density"
SELECT 
    a.zipcode,
    COUNT(p.property_id) AS total_listings,
    RANK() OVER (ORDER BY COUNT(p.property_id) DESC) AS listing_rank
FROM 
    properties p
JOIN 
    addresses a ON p.address_id = a.address_id
GROUP BY 
    a.zipcode
ORDER BY 
    total_listings ASC
limit 15;

"Part 2: Client Service and Broker Performance Insights"
"Section 1: identify properties with price below the area median (rank by what percent below median)"
WITH area_medians AS (
    SELECT 
        a.zipcode,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.price) AS median_price
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    GROUP BY 
        a.zipcode
),
property_with_median AS (
    SELECT 
        p.property_id,
        a.zipcode,
        p.price,
        m.median_price,
        ((m.median_price - p.price) / m.median_price) * 100 AS percent_below_median
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    JOIN 
        area_medians m ON a.zipcode = m.zipcode
    WHERE 
        p.price < m.median_price
)
SELECT 
    property_id,
    zipcode,
    price,
    median_price,
    ROUND(percent_below_median::NUMERIC, 2) AS percent_below_median
FROM 
    property_with_median
WHERE 
    percent_below_median < 90
ORDER BY 
    percent_below_median DESC
limit 20;

"Section 2: Properties with price below the area median (zip code 10025, around Columbia U)"
WITH area_medians AS (
    SELECT 
        a.zipcode,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.price) AS median_price
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    GROUP BY 
        a.zipcode
),
property_with_median AS (
    SELECT 
        p.property_id,
        a.zipcode,
        p.price,
        m.median_price,
        ((m.median_price - p.price) / m.median_price) * 100 AS percent_below_median
    FROM 
        properties p
    JOIN 
        addresses a ON p.address_id = a.address_id
    JOIN 
        area_medians m ON a.zipcode = m.zipcode
    WHERE 
        p.price < m.median_price
)
SELECT 
    property_id,
    zipcode,
    price,
    median_price,
    ROUND(percent_below_median::NUMERIC, 2) AS percent_below_median
FROM 
    property_with_median
WHERE 
    percent_below_median < 90
    AND zipcode = '10025'
ORDER BY 
    percent_below_median DESC;

"Section 3: Identify the broker with greatest number of deals"
SELECT 
    e.name AS employee_name,
    COUNT(t.transaction_id) AS total_deals,
    SUM(p.price) AS total_value
FROM 
    appointments a
JOIN 
    employees e ON a.employee_id = e.employee_id
JOIN 
    properties p ON a.property_id = p.property_id
JOIN 
    transactions t ON p.property_id = t.property_id
GROUP BY 
    e.name
ORDER BY 
    total_deals DESC, total_value DESC
LIMIT 10;

"Section 4: Identify brokers with the greatest amount of deal value"
SELECT 
    e.name AS employee_name,
    COUNT(t.transaction_id) AS total_deals,
    SUM(p.price) AS total_value,
    RANK() OVER (ORDER BY SUM(p.price) DESC) AS value_rank
FROM 
    appointments a
JOIN 
    employees e ON a.employee_id = e.employee_id
JOIN 
    properties p ON a.property_id = p.property_id
JOIN 
    transactions t ON p.property_id = t.property_id
GROUP BY 
    e.name
ORDER BY 
    total_value DESC
LIMIT 10;


