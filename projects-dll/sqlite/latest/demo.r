REBOL []

print "Creating tables ..."

unless value? 'sqlite [ do %sqlite.r ]

;	Clean up from previous runs
error? try [delete %sqlite.log]
error? try [delete %master.db]
error? try [delete %master.db-journal]
error? try [delete %detail.db]
error? try [delete %detail.db-journal]

interval: none

foreach command [
	;	Create Customer (10 rows) and Order (100 rows) records
	[CONNECT/create %master.db]
	[SQL "create table Customers (ID, Name, Address)"]
	[SQL "create table Orders (Customer_ID, Date, Order_ID)"]
	[SQL "begin"]
	[
		repeat i 10 [
			SQL reduce ["insert into Customers values (?, ?, ?)" i join "Name-" i join "Address-" i]
		]
	]
	[p: 0 repeat i 10 [repeat j 10 [SQL reduce ["insert into Orders values (?, ?, ?)" i now/date + i p: p + 1]]]]
	[SQL "commit"]
	[SQL "create unique index CustomersIDX1 on Customers (ID)"]
	[SQL "create index OrdersIDX1 on Orders (Customer_ID)"]
	[SQL "create unique index OrdersIDX2 on Orders (Order_ID)"]
	[SQL "analyze"]
	[DISCONNECT]
	;	Create Items (1000 rows) records
	[CONNECT/create %detail.db]
	[SQL "create table Items (ID, Description, Price, Quantity, Total)"]
	[SQL "begin"]
	[
		repeat i 1000 [
			p: random $100
			q: random 1000
			SQL reduce ["insert into Items values (?,?,?,?,?)" i reform ["Description" i] p q p * q]
		]
	]
	[SQL "commit"]
	[SQL "create unique index ItemsIDX1 on Items (ID)"]
	[SQL "analyze"]
	[DISCONNECT]
	;	Query database
	[interval: 2]
	[CONNECT/format [%master.db %detail.db]]
	[DESCRIBE "customers"]
	[DESCRIBE "orders"]
	[DESCRIBE "items"]
	[SQL "select * from customers"]
	[SQL "select * from orders"]
	[SQL "select * from items"]
	[SQL "select b.* from orders a,items b where a.customer_id = 1 and a.order_id = b.id"]
	[SQL "select name,date,order_id from orders a,customers b where a.customer_id = b.id"]
	[EXPLAIN "select * from customers"]
	[DATABASE]
	[DATABASE/check]
	[TABLES]
	[INDEXES]
	[DISCONNECT]
] [
	if interval [
		print ["^/" mold/only command]
		wait interval
	]
	do command
]