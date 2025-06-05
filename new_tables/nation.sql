CREATE TABLE IF NOT EXISTS nation (
	n_nationkey SMALLINT NOT NULL,
	n_name VARCHAR(25),
	n_comment VARCHAR(152),
	n_regionkey SMALLINT NOT NULL,
	PRIMARY KEY (n_nationkey)
)
