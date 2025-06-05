CREATE TABLE if NOT EXISTS region (
	r_regionkey SMALLINT NOT NULL,
	r_name VARCHAR(25),
	r_comment VARCHAR(152),
	PRIMARY KEY (r_regionkey)
)
