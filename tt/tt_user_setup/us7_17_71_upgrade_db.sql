update tt_db_version set dbv_version = 'converting to 7.17.71'
go

UPDATE tt_customer_default
SET cusd_first_default = 1
WHERE cusd_id IN
(
    SELECT cusd_id
    FROM tt_customer_default c
    INNER JOIN
    (
        SELECT cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        FROM tt_customer_default
        GROUP BY cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        HAVING COUNT(*) > 1
    ) d ON c.cusd_user_id = d.cusd_user_id
        AND c.cusd_comp_id = d.cusd_comp_id
        AND c.cusd_customer = d.cusd_customer
        AND c.cusd_market_id = d.cusd_market_id
        AND c.cusd_gateway_id = d.cusd_gateway_id
        AND c.cusd_product_type = d.cusd_product_type
        AND c.cusd_product = d.cusd_product
    WHERE c.cusd_product_in_hex = '2A'
)
GO

DELETE FROM tt_customer_default
WHERE cusd_id IN
(
    SELECT cusd_id
    FROM tt_customer_default c
    INNER JOIN
    (
        SELECT cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        FROM tt_customer_default
        GROUP BY cusd_user_id, cusd_comp_id, cusd_customer, cusd_market_id, cusd_gateway_id, cusd_product_type, cusd_product
        HAVING COUNT(*) > 1
    ) d ON c.cusd_user_id = d.cusd_user_id
        AND c.cusd_comp_id = d.cusd_comp_id
        AND c.cusd_customer = d.cusd_customer
        AND c.cusd_market_id = d.cusd_market_id
        AND c.cusd_gateway_id = d.cusd_gateway_id
        AND c.cusd_product_type = d.cusd_product_type
        AND c.cusd_product = d.cusd_product
    WHERE c.cusd_product_in_hex = ''
)
GO

UPDATE tt_customer_default SET cusd_product_in_hex = '2A' WHERE cusd_product = '*' AND cusd_product_in_hex = ''
GO

--------------- DON'T DELETE
update tt_db_version set dbv_version = '007.017.071.000'
go
