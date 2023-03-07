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

--******************************************************************************
--************************************Variables - Constant *********************

do $$
declare
counter integer :=1;
first_name varchar(50) := 'John';
last_name varchar(50) := 'Doe';
payment numeric(4,2) :=20.5;--20.50 diye kaydeder. 4'un anlami==>>ondalikli ifadenin tamamı, 2 ise noktadan sonraki olması gereken hane

begin 
raise notice '% % % has been paid % USD',
			 counter, -- 1. %
			 first_name, --2. %
			 last_name, --3. %
			 payment; --4. %
end $$;	

-- Task 1 : değişkenler oluşturarak ekrana " Ahmet ve Mehmet beyler 120 tl ye bilet aldılar. "" cümlesini ekrana basınız

do $$
declare
first_name1 varchar(50) := 'Ahmet';
first_name2 varchar(50) := 'Mehmet';
buy_ticket numeric(3,0) := 120;
begin
raise notice '% ve % beyler % tl ye bilet aldilar',
first_name1,
first_name2,
buy_ticket;
end $$;

-- **************************BEKLETME KOMUTU*****************************
do $$
declare
created_at time := now();
begin
raise notice '%',created_at;
perform pg_sleep(10);
raise notice '%',created_at;
end $$; --execute edildikten sonra artik deger atandi dolayisiyla 10 snden sonra da ayni degeri gordum.

--****************************TABLODAN DATA TIPINI KOPYALAMA*********************************
   /*
		-> variable_name  table_name.column_name%type;
		->( Tablodaki datanın aynı data türünde variable oluşturmaya yarıyor)
	*/
	
do $$
declare
film_title film.title%type;
begin
--1 idli filmin ismini getirelim
select title 
from film
into film_title
where id =1;
raise notice 'Film title id 1: %',film_title;
end $$;

--***********************IC ICE BLOKLAR************************************
do $$
<<outher_block>>
declare
counter integer := 0;
begin 
counter := counter + 1;
raise notice 'The current value of counter is %', counter;
    <<inner_block>>
	declare
	counter integer := 0;
	begin
	counter := counter +10;
	raise notice 'Counter in the subBlock is %', counter;
	raise notice 'Counter in the OutherBlock is %', outher_block.counter;
	end inner_block;
raise notice 'Counter in the outherBlock is %', counter;
--raise notice '%',inner_block.counter; olmuyor bu.

end outher_block $$;

--**********************ROW TYPE*********************
do $$
declare
selected_actor actor%rowtype;
begin
select * from actor
into selected_actor 
where id = 1;
raise notice 'The actor name is % %',selected_actor.isim,
                                   selected_actor.soyisim;
end $$;	
--**************************************RECORD TYPE**************************
/*
   -> Row Type gibi calisir ama recordun tamamı degil de belli basliklari
   almak istersek kullanilabilir.
*/

do $$
declare 
rec record; -- record data turunde rec isminde degisken olusturuldu
begin
select id, title, type 
into rec
from film
where id = 1;
raise notice '% % %', rec.id, rec.title, rec.type;
end $$;

-- ************************CONSTANT********************
do $$
declare
	vat constant numeric := 0.1;
	net_price numeric := 20.5;
begin
	raise notice 'Satis Fiyati : %', net_price*(1+vat);
	-- vat := 0.05; constant bir ifadeyi ilk setleme isleminden sonra degistirmeye calisirsak hata aliriz (final keyword gibidir bu constant kismi)
end $$;
-- constant bir ifadeye Run Time'da deger verebilir miyim?

do $$
declare
	start_at constant time := now();
begin
	raise notice 'Blogun calisma zamani : %', start_at;
end $$;

-- **************************CONTROL STRUCTURES ***************************
-- ***************IF STATEMENT ***********************
--SYNTAX
/*
		if condition then
			statements;
		end if;
*/
-- Task : 1 id li filmi bulalım eğer yoksa ekrana uyarı yazısı verelim

do $$
declare
	_film film%rowtype;
	film_id film.id%type := 1;
begin
	select * from film 
	into _film
	where id = film_id;
	if not found then -- condition == not found
		raise notice 'Girdiginiz idli film bulunamadi : %', film_id; -- statement
    end if;

end $$;

-- *******************IF-THEN-ELSE******************
/*

		IF condition Then
				statement;
		ELSE
			    alternative statement;
		END IF	
	
*/

---- Task : 1 idli film varsa title bilgisini yazınız yoksa uyarı yazısını ekrana basınız
do $$
declare
		_film film%rowtype;
		film_id film.id%type := 1;
begin
		select * from film
		into _film
		where id = film_id;
if found then
		raise notice 'Film Title : %',_film.title;
else
		raise notice 'Girilen id li title bulunamadi : %',film_id;
end if;
end $$;


-- ************* IF-THEN-ELSE-IF ************************


-- syntax : 

/*

	IF condition_1 THEN
				statement_1;
		ELSEIF condition_2 THEN
				statement_2;
	    ELSEIF condition_3 THEN
				statement_3;
		ELSE 
				statement_final;
	END IF ;


*/
/*
Task : 1 id li film varsa ;
			süresi 50 dakikanın altında ise Short,
			50<length<120 ise Medium,
			length>120 ise Long yazalım
*/

do $$
declare
	_film film%rowtype;
	len_description varchar(50);
begin
select * from film
into _film -- _film.id = 1 / _film.title ='Kuzularin Sessizligi'
where id = 1;
		if not found then
		raise notice 'Film bulunamadi';
		else
			 if _film.length > 0 and _film.length < 50 then
				len_description = 'Short';
				 elseif _film.length > 50 and _film.length < 120 then
					len_description = 'Medium';
				 elseif _film.length > 120 then
					len_description = 'Long';
				 else len_description = 'Taninlanamamaktadir.';
			 end if;
	   raise notice ' % Filminin suresi : %',_film.title, len_description;
	   end if; 
	
end $$

-- ***************** CASE STATEMENT *******************************
-- SYNTAX :
/*
	CASE search-expression
	WHEN expression_1 [, expression_2,...] THEN
	statement
	[..]
	[ELSE
	 ELSE-SATEMENT]
	 END case;
*/

-- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım
do $$
declare
	uyari varchar(50);
	movie_type film.type%type;
begin
	select type from film
	into movie_type
	where id = 1;
	if found then
		case movie_type
			when 'Korku' then uyari ='Cocuklar icin uygun degildir';
			when 'Animasyon' then uyari = 'Cocuklar icin tavsiye edilir';
			when 'Macera' then uyari = 'Cocuklar icin uygundur';
			else
			 uyari = 'Tanimlanamamaktadir';
		end case;
		raise notice '%', uyari;
	end if;	
end $$;
