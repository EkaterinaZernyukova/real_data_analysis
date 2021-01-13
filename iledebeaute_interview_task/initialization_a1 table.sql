CREATE TABLE public.a1 (
	id int4 NOT NULL DEFAULT nextval('orders_id_seq'::regclass),
	"name" int4 NULL,
	mix varchar(20) NULL,
	versions varchar(255) NOT NULL DEFAULT 'NOT'::character varying,
	indexs _varchar NULL,
	"text" varchar(255) NULL,
	CONSTRAINT orders_pkey PRIMARY KEY (id),
	CONSTRAINT orders_users_check CHECK ((name > 0))
);


ALTER TABLE public.a1 ADD CONSTRAINT orders_users_fkey FOREIGN KEY (name) REFERENCES present(user_id);


INSERT INTO public.a1 ("name",mix,versions,indexs,"text") VALUES
	 (2,'6','NOT',NULL,'min'),
	 (3,'6','NOT',NULL,'min'),
	 (1,'6','NOT',NULL,'min'),
	 (NULL,'4','NOT',NULL,'max'),
	 (NULL,NULL,'ANY','{sql,postgres,database,plsql}',NULL);