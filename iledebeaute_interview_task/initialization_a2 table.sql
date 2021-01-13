CREATE TABLE public.a2 (
	"text" varchar(255) NULL,
	id int4 NULL,
	"name" bpchar(20) NULL
);

INSERT INTO public.a2 ("text",id,"name") VALUES
	 ('develop',11,'name                '),
	 ('sales',7,'name                '),
	 ('develop',9,'name                '),
	 ('develop',8,'name                '),
	 ('develop',10,'name                '),
	 ('sales',12,NULL);