
CREATE TABLE activation (
	id INTEGER NOT NULL, 
	code VARCHAR(30) NOT NULL, 
	created_by VARCHAR(30) NOT NULL, 
	valid_until DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (code)
);

CREATE TABLE groups (
	id INTEGER NOT NULL, 
	name VARCHAR(100) NOT NULL, 
	created datetime NOT NULL, 
	updated datetime NOT NULL, 
	creator_id INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(creator_id) REFERENCES user (id)
);

CREATE TABLE subscriptions (
	id INTEGER NOT NULL, 
	uri VARCHAR(256) NOT NULL, 
	type VARCHAR(64) NOT NULL, 
	active BOOLEAN NOT NULL, 
	PRIMARY KEY (id), 
	CHECK (active IN (0, 1))
);

CREATE TABLE user (
	id INTEGER NOT NULL, 
	uid VARCHAR(30) NOT NULL, 
	username VARCHAR(30) NOT NULL, 
	admin BOOLEAN DEFAULT 0 NOT NULL, 
	manager BOOLEAN DEFAULT 0 NOT NULL, 
	email VARCHAR(100) NOT NULL, 
	status INTEGER, 
	last_login_date datetime NOT NULL, 
	registered_date datetime NOT NULL, 
	activation_id INTEGER, 
	password VARCHAR(256) NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (uid), 
	UNIQUE (username), 
	CHECK (admin IN (0, 1)), 
	CHECK (staff IN (0, 1)), 
	UNIQUE (email), 
	FOREIGN KEY(activation_id) REFERENCES activation (id)
);

CREATE TABLE user_group (
	user_id INTEGER NOT NULL, 
	group_id INTEGER NOT NULL, 
	FOREIGN KEY(user_id) REFERENCES user (id), 
	FOREIGN KEY(group_id) REFERENCES groups (id)
);

CREATE INDEX subs_uri_idx_subscriptions ON subscriptions (uri);
COMMIT;
