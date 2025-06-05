CREATE TABLE IF NOT EXISTS supplier (
	su_suppkey INT NOT NULL,
	su_nationkey SMALLINT NOT NULL,
	su_name VARCHAR(25),
	su_address VARCHAR(40),
	su_phone VARCHAR(15),
	su_acctbal INT,
	su_comment VARCHAR(101),
	PRIMARY KEY (su_suppkey)
)
