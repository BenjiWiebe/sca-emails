CREATE TABLE IF NOT EXISTS Invoice(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	invnum TEXT UNIQUE NOT NULL,
	invdate TEXT,
	duedate TEXT,
	total TEXT,
	trackingnumbers TEXT,
	ordernumber TEXT,
	ponumber TEXT,
	freight TEXT,
	subtotal TEXT
);

CREATE TABLE IF NOT EXISTS LineItems(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	invid INTEGER NOT NULL,
	qtyordered INTEGER,
	qtyshipped INTEGER,
	partno TEXT,
	description TEXT,
	msrp TEXT,
	cost TEXT,
	totalamount TEXT,
	details TEXT
);
