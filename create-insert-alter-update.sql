--1 Utwórz nową bazę danych o nazwie uczelnia oraz wybierz ją (USE ...).
create database uczelnia;
use uczelnia;
--2 Utwórz nową tabelę o nazwie studenci zawierającą następujące kolumny:
--– nr_indeksu (klucz główny),
--– imie (ciąg znaków, niepuste),
--– nazwisko (ciąg znaków, niepuste),
--– adres (ciąg znaków, niepuste),
--– narodowosc (ciąg znaków, niepuste, domyślnie ‘Polska’).
create table studenci (
	nr_indeksu	int,
	imie		varchar(100)	not null,
	nazwisko	varchar(100)	not null,
	adres		varchar(100)	not null,
	narodowosc	varchar(100)	default 'Polska',
	primary key 	(nr_indeksu)
);
--3 Utwórz nową tabelę o nazwie wykladowcy zawierającą następujące kolumny:
--– wykladowca_id (klucz główny),
--– imie (ciąg znaków, niepuste),
--– nazwisko (ciąg znaków, niepuste).
create table wykladowcy (
	wykladowca_id	int,
	imie		varchar(100)	not null,
	nazwisko	varchar(100)	not null,
	primary key	(wykladowca_id)
);
--4 Utwórz nową tabelę o nazwie kierunki zawierającą następujące kolumny:
--– kierunek_id (klucz główny),
--– nazwa (ciąg znaków, niepuste).
create table kierunki (
	kierunek_id	int,
	nazwa		varchar(255)	not null,
	primary key	(kierunek_id)
);
--5 Utwórz nową tabelę o nazwie przedmioty zawierającą następujące kolumny:
--– przedmiot_id (klucz główny),
--– kierunek_id (klucz obcy z tabeli kierunki, niepuste),
--– wykladowca_id (klucz obcy z tabeli wykladowcy, niepuste),
--– nazwa (ciąg znaków, niepuste).
create table przedmioty (
	przedmiot_id	int,
	kierunek_id	int foreign key references kierunki(kierunek_id)	not null,
	wykladowca_id	int foreign key references wykladowcy(wykladowca_id)	not null,
	nazwa		varchar(255)						not null,
	primary key	(przedmiot_id)
);
--6 Utwórz nową tabelę o nazwie studenci_przedmioty zawierającą następujące kolumny:
--– nr_indeksu (klucz obcy z tabeli studenci),
--– przedmiot_id (klucz obcy z tabeli przedmioty),
--– (klucz główny tej tabeli powinny stanowić nr_indeksu oraz przedmiot_id)
create table studenci_przedmioty (
	nr_indeksu	int foreign key references studenci(nr_indeksu),
	przedmiot_id	int foreign key references przedmioty(przedmiot_id),
	primary key	(nr_indeksu, przedmiot_id)
);
--7 Utwórz nową tabelę o nazwie oceny zawierającą następujące kolumny:
--– ocena_id (klucz główny),
--– nr_indeksu (klucz obcy z tabeli studenci, niepuste),
--– przedmiot_id (klucz obcy z tabeli przedmioty, niepuste),
--– wartosc (liczba z częściami dziesiętnymi, niepuste, domyślnie ‘2.0’),
--– data (data, niepuste, domyślnie aktualna data) (GETDATE()).
create table oceny (
	ocena_id	int,
	nr_indeksu	int foreign key references studenci(nr_indeksu)		not null,
	przedmiot_id	int foreign key references przedmioty(przedmiot_id) 	not null,
	wartosc		decimal(2,1)						default 2.0,
	data		date							default getdate(),
	primary key	(ocena_id)
);
--8 Zmodyfikuj tabele (ALTER TABLE ...) dodając:
--– (tabela oceny) ograniczenie niepozwalające na wstawianie ocen o wartościach mniejszych niż 2.0 oraz większych niż 5.0,
--– (tabela przedmioty) ograniczenie niepozwalające na dodawanie przedmiotów o takich samych nazwach (UNIQUE),
--– (tabela kierunki) ograniczenie niepozwalające na dodawanie kierunków o takich samych nazwach,
--– (tabela kierunki) nową kolumnę o nazwie opis typu text, z domyślą wartością równą ‘pusty opis’.
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
--9 Wypełnij utworzone wcześniej tabele przykładowymi danymi (polecenie INSERT), tak aby każda tabela zawierała co najmniej trzy wiersze (krotki).
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
--10 Zmień wszystkie oceny (wszystkim studentom) o wartości 2.0 na 3.0 (UPDATE).
update oceny
set wartosc = 3.0
where wartosc = 2.0;
