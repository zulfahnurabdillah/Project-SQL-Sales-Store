use sales_store
select * from sales_table


--data cleaning

--dupilcated value
select transaction_id, count(*)
from sales_table
group by transaction_id
having count(transaction_id) > 1

with duplicated as (
select *,
	row_number() over(partition by transaction_id order by transaction_id) as row_num
from sales_table
)
DELETE FROM duplicated WHERE row_num > 1;

--fix headers
select * from sales_table
exec sp_rename 'sales_table.quantiy', 'quantity', 'column'
exec sp_rename 'sales_table.prce', 'price', 'column'

--check dtype
select column_name, data_type
from INFORMATION_SCHEMA.columns
where table_name = 'sales_table'

--check null values
declare @sql  nvarchar(max) = '';

select @sql = string_agg(
	'select ''' + column_name + ''' as column_name, '+
	'count(*) as null_count ' +
	'from' + quotename(table_schema) + '.' + quotename(table_name) + ' ' +
	'where ' + quotename(column_name) + ' is null',
	' union all '
)

within group (order by column_name)
from information_schema.columns
where table_name = 'sales_table'

exec sp_executesql @sql;

--fix null values
select * from sales_table
where transaction_id is null
or customer_id is null 
or customer_name is null
or customer_age is null
or gender is null
or product_category is null
or product_name is null
or product_id is null
or quantity is null
or price is null
or payment_mode is null
or purchase_date is null
or time_of_purchase is null
or status is null

delete from sales_table
where transaction_id is null

select * from sales_table
where customer_name = 'Ehsaan Ram'

update sales_table
set customer_id = 'CUST9494'
where transaction_id = 'TXN977900'

select * from sales_table
where customer_name = 'Damini Raju'

update sales_table
set customer_id = 'CUST1401'
where transaction_id = 'TXN985663'

select * from sales_table
where customer_id = 'CUST1003'

update sales_table
set customer_name = 'Mahika Saini',
	customer_age = '35',
	gender = 'Male'
where transaction_id = 'TXN432798'

--Data Cleaning 
select * from sales_table
select distinct gender from sales_table

update sales_table
set gender = 'M'
where gender = 'Male'

update sales_table
set gender = 'F'
where gender = 'Female'

select distinct payment_mode from sales_table

update sales_table
set payment_mode = 'Credit Card'
where payment_mode = 'CC'

--Data Analysis

--1. What Are The Top 5 Most Selling Product by Quantity
select * from sales_table
select distinct status from sales_table

select top 5 
	product_name,
	sum(quantity) as Jumlah_Pennjualan
from sales_table
where status = 'delivered'
Group by product_name
order by Jumlah_Pennjualan desc
--Bussines Problem	: Kita Tidak Tau Produk Mana Yang Memiliki Penjualan Terbanyak(In Demand)
--Wardrobe			70
--Vegetables		69
--Sofa				66
--Dining Table		65
--Fruits			60
--Business Impact	: Membantu Produk Mana Yang akan Dipriotitaskan dan Mendorong Penjualan Agar Memenuhi Target Promosi

--2. Which Products Are Most Frequently Cancelled
select * from sales_table

select 
	product_name, 
	count(status) as Jumlah_Product_Cancel
from sales_table
where status = 'cancelled'
group by product_name
order by Jumlah_Product_Cancel desc
--Bussines Problem	: Melihat Frekuensi Produk Cancel Yang Mempengaruhi Penghasilan dan Kepercayaan Customer
--Comics		24
--Sweater		23
--Vegetables	21
--Chair			21
--Shirt			20
--Bussines Impact	: Mengidentifikasi Produk Yang Memiliki Performa Yang Rendah Untuk Meningkatkan 
--Kualitas Atau Menghapus Produk Dari Katalog

--3. What Time of The Day Has The Highest Number of Purchase
select * from sales_table

select
	case
		when datepart(hour, time_of_purchase) between 0 and 5 then 'Night'
		when datepart(hour, time_of_purchase) between 6 and 11 then 'Morning'
		when datepart(hour, time_of_purchase) between 12 and 17 then 'Afternoon'
		when datepart(hour, time_of_purchase) between 18 and 23 then 'Evening'
	end as Waktu_Penjualan,
	count(*) as Jumlah_Order
	from sales_table
	group by
	case
		when datepart(hour, time_of_purchase) between 0 and 5 then 'Night'
		when datepart(hour, time_of_purchase) between 6 and 11 then 'Morning'
		when datepart(hour, time_of_purchase) between 12 and 17 then 'Afternoon'
		when datepart(hour, time_of_purchase) between 18 and 23 then 'Evening'
	end
	order by Jumlah_Order desc
--Bussines Problem	: Cari kapan Waktu Penjualan tertinggi
--Evening	515
--Morning	514
--Night		496
--Afternoon	475
--Bussines Impact	: Mengoptimalkan Staf, Mobilitas, dan Beban Server

--4. Who Are The Top 5 Highest Spending Customers
select * from sales_table

select top 5
	customer_name,
	format(sum(price*quantity),'c0', 'en-in') as jumlah_belanja_customers
from sales_table
group by customer_name
order by jumlah_belanja_customers desc
--Bussines Problem	: identifikasi VIP Customers
--Jayant Goyal			₹ 99,583
--Shlok Cheema			₹ 98,139
--Saira Handa			₹ 97,428
--Tushar Subramanian	₹ 97,100
--Zeeshan Barad			₹ 96,844
--Bussines Impact	: Penawaran Personal, Hadiah Loyalitas, dan Retensi

--Which Products Categories Generate The Highest Revenue
select * from sales_table

select 
	product_category,
	format(sum(price*quantity),'c0', 'en-in') as penghasilan_kategori_produk
from sales_table
group by product_category
order by sum(price*quantity) desc
--Bussines Problem	: Cari Produk kategori dengan penghasilan tertinggi
--Bussines Impact	: Menyempurnakan strategi produk menyempurnakan strategi produk, supply chain, dan promosi
--Accessories	₹ 1,03,65,306
--Clothing		₹ 1,01,95,727
--Books			₹ 99,12,929
--Furniture		₹ 96,59,478
--Electronics	₹ 95,04,028
--Groceries		₹ 94,64,153
--memungkinkan perusahaan untuk berinvestasi lebih banyak pada margin tinggi atau katgori dengan permintaan tinggi

--6. What is the status(cancel,return,deliver,pending) rate per product category
select * from sales_table
select distinct status from sales_table
select 
	product_category,
	format(count(case when status = 'cancelled' then 1 end)*100.0/count(*), 'N2')+' %' as persen_cancel,
	format(count(case when status = 'returned' then 1 end)*100.0/count(*), 'N2')+' %' as persen_return,
	format(count(case when status = 'delivered' then 1 end)*100.0/count(*), 'N2')+' %' as persen_deliver,
	format(count(case when status = 'pending' then 1 end)*100.0/count(*), 'N2')+' %' as persen_pending
from sales_table
group by product_category

--Bussines Problem	: Monitor untuk tren ketidakpuasan per kategori
--Groceries		22.29 %	23.49 %	28.61 %	25.60 %
--Clothing		25.63 %	24.79 %	20.56 %	29.01 %
--Accessories	23.55 %	31.50 %	20.49 %	24.46 %
--Electronics	24.68 %	20.78 %	21.43 %	33.12 %
--Furniture		22.83 %	23.41 %	28.03 %	25.72 %
--Books			26.20 %	25.60 %	23.80 %	24.40 %
--Bussines Impact	: Mengurangi angka pengembalian kedepannya, meningkatkan ekspetasi/deskripsi produk,
--membantu mengidentifikasi dan memperbaiki produk dan masalah logistik

--7. What Is The Most Prefered Payment Mode
select * from sales_table

select 
	payment_mode,
	count(*) as total_payment_mode
from sales_table
group by payment_mode
order by total_payment_mode desc
--Bussines Problem	= Apa jenis pembayaran customer paling disukai/diminati
--Credit Card	648
--EMI			350
--Debit Card	344
--Cash			332
--UPI			326
--Bussines Impact	= Menyederhanakan proses pembayaran, memprioritaskan jenis pembayaran yang populer

--8. How Does Age Group Affect Purchasing Behavior
select * from sales_table
select distinct customer_age from sales_table 
order by customer_age desc

select
	case
		when customer_age between 18 and 27 then 'Gen Z'
		when customer_age between 28 and 40 then 'Milenial'
		when customer_age between 41 and 60 then 'Boomer'
	end as customer_gen,
	format(sum(price*quantity),'c0', 'en-in') as Total_Pembelian
from sales_table
group by 
		case
		when customer_age between 18 and 27 then 'Gen Z'
		when customer_age between 28 and 40 then 'Milenial'
		when customer_age between 41 and 60 then 'Boomer'
	end
order by Total_Pembelian desc
--Bussines Problem	: Bagimana Demographic dari customer
--Boomer	₹ 2,69,96,215
--Milenial	₹ 1,85,07,140
--Gen Z		₹ 1,35,98,266
--Bussines Impact	: Mengerti target penjualan dari usia dan rekomendasi produk by age

--9. What's The Monthly Sales Trend
select * from sales_table

select 
	format(purchase_date, 'yyyy-MM') as Month,
	format(sum(price*quantity),'c0', 'en-in') as Total_Pembelian,
	sum(quantity) as Total_Quantity
from sales_table
group by format(purchase_date, 'yyyy-MM')
--Alternative 
select 
	month(purchase_date) as Months,
	format(sum(price*quantity),'c0', 'en-in') as Total_Pembelian,
	sum(quantity) as Total_Quantity
from sales_table
group by month(purchase_date)
order by Months
--Bussines Problem	: fluktuasi penjualan tidak disadari
--1		₹ 49,68,050	509
--2		₹ 46,98,929	529
--3		₹ 52,41,364	471
--4		₹ 49,89,315	505
--5		₹ 39,02,263	418
--6		₹ 41,00,112	478
--7		₹ 51,29,904	577
--8		₹ 47,88,207	497
--9		₹ 50,37,847	512
--10	₹ 58,86,414	547
--11	₹ 51,09,229	523
--12	₹ 52,49,987	521
--Bussines Impact	: Merencanakan inventaris dan pemasaran sesuai dengan bulan penjualan

--10. Are Certain Genders Buying More Spesific Product Categories
select * from sales_table

select 
	gender,
	product_category,
	count(product_category) as jumlah_produk
from sales_table
group by gender, product_category
order by jumlah_produk desc
--alternative
select *
from (
	select gender, product_category
	from sales_table) as source_table
pivot (
	count(gender)
	for gender in ([M],[F])
	) as pivot_table
order by product_category
--Bussines Problem	: Referensi produk berdasarkan gender
--Accessories	171	156
--Books			180	152
--Clothing		175	180
--Electronics	161	147
--Furniture		163	183
--Groceries		167	165
--Bussines Impact	: iklan personal, meningkatkan iklan berdasarkan gender

