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

--Task 1 : Film tablosundaki film sayısı 10 dan az ise "Film sayısı az" yazdırın,
--         10 dan çok ise "Film sayısı yeterli" yazdıralım

do $$ --anonim method, database'e kaydedilmeyecek anlami ihtiva etmekte "do"
declare
	_number integer := 0;
begin
	select count(*) from film
	into _number;
	if(_number < 10) then
		raise notice 'Film sayisi az';
	else
		raise notice 'Film sayisi yeterli';
	end if;
end $$;
-- Task 2: user_age isminde integer data türünde bir değişken tanımlayıp default olarak bir değer verelim, 
--If yapısı ile girilen değer 18 den büyük ise Access Granted,
--küçük ise Access Denied yazdıralım
do $$
declare
	user_age integer = random()*10 +1;
begin

	if (user_age > 18) then
	raise notice 'Age 18 den buyuk';
	else
	raise notice 'Age 18den kucuk ';
	end if;
end $$;

-- Task 3: a ve b isimli integer türünde 2 değişken tanımlayıp default değerlerini verelim, 
--eğer a nın değeri b den büyükse "a , b den büyüktür" yazalım, tam tersi durum için "b, a dan büyüktür" yazalım, 
--iki değer birbirine eşit ise " a,  b'ye eşittir" yazalım:
do $$
declare
	a integer = random()*5+3;
	b integer = random()*5+3;
begin
	if(a > b) then
	raise notice 'a b den buyuktur a=% b=%',a,b;
	elseif(b > a) then
	raise notice 'b a dan buyuktur a=% b=%',a,b;
	else
	raise notice 'a b ye esittir a=% b=%',a,b;
	end if;
end $$;

do $$
declare
    a integer = random()*5 + 1;
    b integer = random()*0;
begin
    if((a/b)>1) then
    raise notice 'a b den buyuktur a=% b=%',a,b;
    elseif((b/a)<1) then
    raise notice 'b a dan kucuktur a=% b=%',a,b;
	elseif((b/a)>1) then
	raise notice 'b a dan buyuktur b=% a=%',b,a;
    elseif((a/b)=0) or ((b/a)=0)then
    raise notice 'payda sifir olamaz a=% b=%',a,b;
    else
    raise notice 'tanimsiz a=% b=%',a,b;
    end if;
end $$;

do $$
declare
    a numeric(3,1) = random()*5-1;
    b numeric(3,1) = (random()*5-1);
begin
    if(((a / b)>0)or((b/a)>0)) then
    raise notice 'a/b sifirdan buyuktur a=% b=%',a,b;
    elseif((a/b)=0) or ((b/a)=0)then
    raise notice 'a veya b sifira esittir a=% b=%',a,b;
    raise exception 'tanimsiz a=% b=%',a,b
    using hint = 'sifir harici sayilar kullanin';
    elseif(((a / b)<0)or((b/a)<0)) then
    raise notice 'b/a sifirdan kucuktur a=% b=%',a,b;
    raise exception 'negeatif a=% b=%',a,b
    using hint = 'negatif gelmesin';
    else
    raise notice 'tanimsiz';
    end if;
end $$;
---- Task 4 : kullaniciYasi isimli bir değişken oluşturup default değerini verin, 
--girilen yaş 18 den büyükse "Oy kullanabilirsiniz", 18 den küçük ise "Oy kullanamazsınız" yazısını yazalım.
do $$
declare
	user_age integer = random()*20+8;
begin
    if(user_age > 18) then
	raise notice 'yasiniz=% oy kullanabilirsiniz',user_age;
	else
	raise notice 'yasiniz=% oy kullanamazsiniz',user_age;
	end if;
end $$;

--  ************** LOOP *************************************

-- syntax 

LOOP
	statement;
END LOOP;

-- loop u sonlandırmak için loopun içine if yapısını kullanabilirz :

LOOP
	statements;
	IF condition THEN
		exit; -- loop dan çıkmamı sağlıyor
	END IF;
END LOOP;

-- nested loop 

<<outher>>
LOOP
	statements;
	<<inner>>
	LOOP
		.....
		exit <<inner>>
		END LOOP;
END LOOP;
-- Task : Fibonacci serisinde, belli bir sıradaki sayıyı ekrana getirelim

do $$
declare
	n integer = random()*40+1;
	counter integer = 0;
	i integer = 0;
	j integer = 1;
	fibo integer = 0;
begin
	if(n<1) then
	fibo = 0;
	end if;
	LOOP
		exit when counter = n;
		counter = counter + 1;
		select j, (i+j) into i,j;
	END LOOP;
	fibo = i;
	raise notice 'fibo=% n=%',fibo,n;
end $$;
-- ************ WHILE LOOP *************************
syntax :
WHILE condition LOOP
	statements;
END LOOP;

-- Task : 1 dan 4 e kadar counter değerlerini ekrana basalım
do $$
declare
	n integer = 4;
	counter integer = 0;
begin
	while counter < n loop
		counter = counter + 1;
		raise notice 'counter = %',counter;
	end loop;	
end $$;
--2nd way:
do $$
declare
	counter integer = 0;
begin
	while counter < 5 loop
	counter = counter + 1;
	raise notice 'counter = %',counter;
	end loop;
end $$;



