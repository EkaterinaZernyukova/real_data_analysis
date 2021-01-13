CREATE TABLE public.a1 (
	id int4 NOT NULL,
	"text" varchar(255) NULL,
	CONSTRAINT orders_pkey PRIMARY KEY (id),
	CONSTRAINT orders_users_check CHECK ((name > 0))
);




INSERT INTO public.a1 ("name",mix,versions,indexs,"text") VALUES
	 (2,'min'),
	 (6, NULL),
	 (9,'min'),
	 (7,'min'),
	 (9,'max'),
	 (8,,NULL);