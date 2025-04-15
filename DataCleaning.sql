--DROPING UNECESSARY COLUMNS (WHICH WON'T BE REQUIRED FOR ANALYSIS)
ALTER TABLE T.ordermaster
drop column createdon, modifiedon, createdbyid,modifiedbyid,deliveredbyid,canceldate,cancelreasonid,deliveryassignedto,deliveryamount,cardpercent,cardcharges,isactive
ALTER TABLE T.orderdetails
DROP COLUMN discountamount,gstamount,createdon,modifiedon,modifiedbyid,createdbyid,gst,unitprice,taxableamount,quantity,productdetailsid, isactive
ALTER TABLE T.userinfo
DROP COLUMN [Password],firstname,lastname,addressline1,addressline2,emailid,createdon,modifiedon,modifiedbyid,createdbyid,phoneno,postalcode,city,username
ALTER TABLE T.refundmaster
DROP COLUMN createdon, createdbyid, modifiedbyid,transactionmasterid,invoicemasterid,paymentmasterid,isactive
ALTER TABLE T.discount
DROP COLUMN createdon,modifiedon,modifiedbyid,createdbyid,isproduct,isactive
ALTER TABLE T.productmaster
DROP COLUMN creadtedon,createdbyid,modifiedon,modifiedbid,productavailability,productrating,baseimage,comparingprice,islatest,gst
ALTER TABLE T.category
DROP COLUMN createdon,createdbyid,modifiedon, modifiedbyid,categoryimage,isactive
ALTER TABLE T.subcategory
DROP column isactive,createdon, createdbyid, modifiedon, modifiedbyid
--WHEREEVER DISCOUNTAMOUNT = NULL  REPLACE WITH 0.00
update t.ordermaster
set discountamount = 0.00
where discountapplied = 0
--- ADDING COLUMNS WHICH ARE REQUIRED FOR ANALYSIS
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ordermaster' AND COLUMN_NAME = 'month'
)
BEGIN
    ALTER TABLE t.ordermaster
    ADD [month] INT
END
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ordermaster' AND COLUMN_NAME = 'quarter'
)
BEGIN
    ALTER TABLE t.ordermaster
    ADD [quarter] INT
END
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ordermaster' AND COLUMN_NAME = 'financialyear'
)
BEGIN
    ALTER TABLE t.ordermaster
    ADD [financialyear] INT
END
--DERIVED   MONTH AND  FINANCIAL QUARTER  AND FINANCIALYEAR FROM ORDERDATE
DECLARE @r INT , @l INT, @temp_date DATE, @temp_month INT, @temp_quarter INT, @temp_year INT
set @r = 1
select @l = count(ordermasterid)   from t.ordermaster
while (@r <= @l)
BEGIN
	select  @temp_month = month(orderdate) from t.ordermaster
	where ordermasterid = @r
	select @temp_year =  year(orderdate) from t.ordermaster
	where ordermasterid = @r
	if @temp_month > 3 and @temp_month <= 6
	begin
		set @temp_quarter = 1
	end
	else if @temp_month > 6and @temp_month <=9
	begin
		set @temp_quarter = 2
	end
	else if @temp_month > 9 and @temp_month <=12
	BEGIN
		set @temp_quarter = 3
	END
	else
	BEGIN
		set @temp_quarter = 4
	END
	UPDATE T.ordermaster
	set
	[month] = @temp_month,
	[quarter] = @temp_quarter,
	financialyear = @temp_year
	where ordermasterid = @r
	set @r = @r+1
END