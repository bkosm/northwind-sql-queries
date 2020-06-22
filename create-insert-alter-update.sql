--1 Utwórz nową bazę danych o nazwie uczelnia oraz wybierz ją (USE ...).

CREATE DATABASE uczelnia;
USE uczelnia;

--2 Utwórz nową tabelę o nazwie studenci zawierającą następujące kolumny:
--– nr_indeksu (klucz główny),
--– imie (ciąg znaków, niepuste),
--– nazwisko (ciąg znaków, niepuste),
--– adres (ciąg znaków, niepuste),
--– narodowosc (ciąg znaków, niepuste, domyślnie ‘Polska’).

CREATE TABLE studenci (
	nr_indeksu	INT PRIMARY KEY,
	imie		VARCHAR(100) NOT NULL,
	nazwisko	VARCHAR(100) NOT NULL,
	adres		VARCHAR(100) NOT NULL,
	narodowosc	VARCHAR(100) DEFAULT 'Polska'
);

--3 Utwórz nową tabelę o nazwie wykladowcy zawierającą następujące kolumny:
--– wykladowca_id (klucz główny),
--– imie (ciąg znaków, niepuste),
--– nazwisko (ciąg znaków, niepuste).

CREATE TABLE wykladowcy (
	wykladowca_id	INT PRIMARY KEY,
	imie		VARCHAR(100) NOT NULL,
	nazwisko	VARCHAR(100) NOT NULL
);

--4 Utwórz nową tabelę o nazwie kierunki zawierającą następujące kolumny:
--– kierunek_id (klucz główny),
--– nazwa (ciąg znaków, niepuste).

CREATE TABLE kierunki (
	kierunek_id	INT PRIMARY KEY,
	nazwa		VARCHAR(255) NOT NULL
);

--5 Utwórz nową tabelę o nazwie przedmioty zawierającą następujące kolumny:
--– przedmiot_id (klucz główny),
--– kierunek_id (klucz obcy z tabeli kierunki, niepuste),
--– wykladowca_id (klucz obcy z tabeli wykladowcy, niepuste),
--– nazwa (ciąg znaków, niepuste).

CREATE TABLE przedmioty (
	przedmiot_id	INT PRIMARY KEY,
	kierunek_id	INT FOREIGN KEY REFERENCES kierunki(kierunek_id) NOT NULL,
	wykladowca_id	INT FOREIGN KEY REFERENCES wykladowcy(wykladowca_id) NOT NULL,
	nazwa		VARCHAR(255) NOT NULL
);

--6 Utwórz nową tabelę o nazwie studenci_przedmioty zawierającą następujące kolumny:
--– nr_indeksu (klucz obcy z tabeli studenci),
--– przedmiot_id (klucz obcy z tabeli przedmioty),
--– (klucz główny tej tabeli powinny stanowić nr_indeksu oraz przedmiot_id)

CREATE TABLE studenci_przedmioty (
	nr_indeksu	INT FOREIGN KEY REFERENCES studenci(nr_indeksu),
	przedmiot_id	INT FOREIGN KEY REFERENCES przedmioty(przedmiot_id),
	PRIMARY KEY (nr_indeksu, przedmiot_id)
);

--7 Utwórz nową tabelę o nazwie oceny zawierającą następujące kolumny:
--– ocena_id (klucz główny),
--– nr_indeksu (klucz obcy z tabeli studenci, niepuste),
--– przedmiot_id (klucz obcy z tabeli przedmioty, niepuste),
--– wartosc (liczba z częściami dziesiętnymi, niepuste, domyślnie ‘2.0’),
--– data (data, niepuste, domyślnie aktualna data) (GETDATE()).

CREATE TABLE oceny (
	ocena_id	INT PRIMARY KEY,
	nr_indeksu	INT FOREIGN KEY REFERENCES studenci(nr_indeksu) NOT NULL,
	przedmiot_id	INT FOREIGN KEY REFERENCES przedmioty(przedmiot_id) NOT NULL,
	wartosc		DECIMAL(2,1) DEFAULT 2.0,
	data		DATE DEFAULT GETDATE()
);

--8 Zmodyfikuj tabele (ALTER TABLE ...) dodając:
--– (tabela oceny) ograniczenie niepozwalające na wstawianie ocen o wartościach mniejszych niż 2.0 oraz większych niż 5.0,
--– (tabela przedmioty) ograniczenie niepozwalające na dodawanie przedmiotów o takich samych nazwach (UNIQUE),
--– (tabela kierunki) ograniczenie niepozwalające na dodawanie kierunków o takich samych nazwach,
--– (tabela kierunki) nową kolumnę o nazwie opis typu text, z domyślą wartością równą ‘pusty opis’.

ALTER TABLE oceny
ADD CHECK(wartosc >= 2.0 AND wartosc <= 5.0);
--
ALTER TABLE przedmioty
ADD UNIQUE(nazwa);
--
ALTER TABLE kierunki
ADD UNIQUE(nazwa);
--
ALTER TABLE kierunki
ADD opis TEXT DEFAULT 'pusty opis';

--9 Wypełnij utworzone wcześniej tabele przykładowymi danymi (polecenie INSERT), tak aby każda tabela zawierała co 
--  najmniej trzy wiersze (krotki).

INSERT INTO studenci
VALUES (100000, 'Bartosz', 'Kosmala', 'Sucha 30', 'Polska');
INSERT INTO studenci (nr_indeksu, imie, nazwisko, adres)
VALUES (100010, 'John', 'Kowalski', 'Smolna 2');
INSERT INTO studenci
VALUES (100100, 'Marta', 'Nowa', 'Gdyńska 38', 'Niemcy');
--
INSERT INTO wykladowcy
VALUES (1, 'Tomasz', 'Blisko');
INSERT INTO wykladowcy
VALUES (2, 'Marcin', 'Mocno');
INSERT INTO wykladowcy
VALUES (3, 'Jolanta', 'Szybka');
--
INSERT INTO kierunki (kierunek_id, nazwa)
VALUES (1, 'Informatyka');
INSERT INTO kierunki
VALUES (2, 'Elektronika i Telekomunikacja', 'Dwa semestry maks');
INSERT INTO kierunki
VALUES (3, 'Budownictwo', 'Cyk budynek');
--
INSERT INTO przedmioty
VALUES (1, 1, 2,'Bazy Danych');
INSERT INTO przedmioty
VALUES (2, 2, 3,'Teoria Obwodów');
INSERT INTO przedmioty
VALUES (3, 1, 1,'Technologie sieciowe');
--
INSERT INTO studenci_przedmioty
VALUES (100000, 1);
INSERT INTO studenci_przedmioty
VALUES (100010, 3);
INSERT INTO studenci_przedmioty
VALUES (100100, 2);
--
INSERT INTO oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
VALUES (1, 100100, 2, 3.0);
INSERT INTO oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
VALUES (2, 100010, 1, 4.5);
INSERT INTO oceny (ocena_id, nr_indeksu, przedmiot_id, wartosc)
VALUES (3, 100000, 3, 2.0);

--10 Zmień wszystkie oceny (wszystkim studentom) o wartości 2.0 na 3.0 (UPDATE).

UPDATE oceny
SET wartosc = 3.0
WHERE wartosc = 2.0;
