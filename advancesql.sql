CREATE TABLE film
(
id int ,
title VARCHAR(50),
type VARCHAR(50),
length int
);
INSERT INTO film VALUES (1, 'Kuzuların Sessizliği', 'Korku',130);
INSERT INTO film VALUES (2, 'Esaretin Bedeli', 'Macera', 125);
INSERT INTO film VALUES (3, 'Kısa Film', 'Macera',40);
INSERT INTO film VALUES (4, 'Shrek', 'Animasyon',85);

CREATE TABLE actor
(
id int ,
isim VARCHAR(50),
soyisim VARCHAR(50)
);
INSERT INTO actor VALUES (1, 'Christian', 'Bale');
INSERT INTO actor VALUES (2, 'Kevin', 'Spacey');
INSERT INTO actor VALUES (3, 'Edward', 'Norton');
do $$
declare
    film_count integer :=0;

begin 
	select count(*) --kac tane film varsa sayisini getirir
	into film_count --queryden gelen neticeyi film_count isimli degiskeni atar
	from film;
	raise notice 'The number of films are %',film_count; --%isareti yer tutucudur

end $$;
