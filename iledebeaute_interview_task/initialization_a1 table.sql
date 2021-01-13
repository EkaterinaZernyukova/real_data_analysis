CREATE TABLE public.a1 (
	id int4 NOT NULL,
	"text" varchar(255) NULL
--	CONSTRAINT orders_pkey PRIMARY KEY (id)
);




INSERT INTO public.a1 ("id","text") VALUES
	 (1,'min'),
	 (6, NULL),
	 (9,'min'),
	 (7,'min'),
	 (9,'max'),
	 (8, NULL),
	 (2,'min'),
	 (6, NULL),
	 (9,'min'),
	 (7,'min'),
	 (9,'max');