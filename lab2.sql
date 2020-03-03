--2
create table studenci (
	nr_indeksu	int,
	imie		varchar(100)	not null,
	nazwisko	varchar(100)	not null,
	adres		varchar(100)	not null,
	narodowosc	varchar(100)	default 'Polska',
	primary key (nr_indeksu)
);
--3
create table wykladowcy (
	wykladowca_id	int,
	imie			varchar(100)	not null,
	nazwisko		varchar(100)	not null,
	primary key		(wykladowca_id)
);
--4
create table kierunki (
	kierunek_id		int,
	nazwa			varchar(255)	not null,
	primary key		(kierunek_id)
);
--5
create table przedmioty (
	przedmiot_id	int,
	kierunek_id		int foreign key references kierunki(kierunek_id)		not null,
	wykladowca_id	int foreign key references wykladowcy(wykladowca_id)	not null,
	nazwa			varchar(255)											not null,
	primary key		(przedmiot_id)
);
--6
create table studenci_przedmioty (
	nr_indeksu		int foreign key references studenci(nr_indeksu),
	przedmiot_id	int foreign key references przedmioty(przedmiot_id),
	primary key		(nr_indeksu, przedmiot_id)
);
--7
create table oceny (
	ocena_id		int,
	nr_indeksu		int foreign key references studenci(nr_indeksu)		not null,
	przedmiot_id	int foreign key references przedmioty(przedmiot_id) not null,
	wartosc			decimal(2,1)										default 2.0,
	data			date												default getdate(),
	primary key		(ocena_id)
);
--8
alter table oceny
add check(wartosc >= 2.0 and wartosc <= 5.0);
--
alter table przedmioty
add unique(nazwa);
--
alter table kierunki
add unique(nazwa);
--
alter table kierunki
add opis text default 'pusty opis';
--9
insert into studenci
values (100000, 'Bartosz', 'Kosmala', 'Sucha 30', 'Polska');
insert into studenci (nr_indeksu, imie, nazwisko, adres)
values (100010, 'John', 'Kowalski', 'Smolna 2');
insert into studenci
values (100100, 'Marta', 'Nowa', 'Gdyńska 38', 'Niemcy');
--
insert into wykladowcy
values (1, 'Tomasz', 'Blisko');
insert into wykladowcy
values (2, 'Marcin', 'Mocno');
insert into wykladowcy
values (3, 'Jolanta', 'Szybka');
--
insert into kierunki (kierunek_id, nazwa)
values (1, 'Informatyka');
insert into kierunki
values (2, 'Elektronika i Telekomunikacja', 'Dwa semestry maks');
insert into kierunki
values (3, 'Budownictwo', 'Cyk budynek');
--
insert into przedmioty
values (1, 1, 2,'Bazy Danych');
insert into przedmioty
values (2, 2, 3,'Teoria Obwodów');
insert into przedmioty
values (3, 1, 1,'Technologie sieciowe');
--
insert into studenci_przedmioty
values (100000, 1);
insert into studenci_przedmioty
values (100010, 3);
insert into studenci_przedmioty
values (100100, 2);
--
insert into oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
values (1, 100100, 2, 3.0);
insert into oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
values (2, 100010, 1, 4.5);
insert into oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
values (3, 100000, 3, 2.0);
--10
update oceny
set wartosc = 3.0
where wartosc = 2.0;
