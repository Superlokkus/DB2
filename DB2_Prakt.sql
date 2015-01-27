insert into Mitarbeiter (MitID,Nachname,Vorname,Ort,Gebdat,Beruf,Telnr) values
('115','Mickey','Mouse','Disneyland','1959-06-27','Dipl-Ing.','491908989890');

insert into Mitarbeiter (MitID,Nachname,Vorname,Ort,Gebdat,Beruf,Telnr) values
('119','Rubble','Barney','Steintal','1957-09-24','Ing.','555');

insert into Mitarbeiter (MitID,Nachname,Vorname,Ort,Gebdat,Beruf,Telnr) values
('135','Feuerstein','Fred','Steintal','1979-11-11','Vertreter','555666');

insert into Mitarbeiter (MitID,Nachname,Vorname,Ort,Gebdat,Beruf,Telnr) values
('145','Feuerstein','Wilma','Steintal','1985-12-24','Dipl.Ing.','005666');

--2 2
update Projekt set Projekt.MitID =
(select Mitarbeiter.MitID from Mitarbeiter where Projekt.Leiter = Mitarbeiter.Nachname)

alter table Projekt drop Leiter;

sp_rename "Projekt.MitID" , LeiterID;

-- 2 3
insert into Mitarbeiter (MitID,Nachname,Vorname,Ort,Gebdat,Beruf,Telnr) values
('146','Klemm','Markus','Dresden','1988-05-05','Dipl.-Ing.','0055');

insert into Projekt (ProNr,Proname,Beschreibung,Aufwand,LeiterID) values
(46,'Sybase-Prakt','Who cares about the SQL standard',4,'146');

insert into Zuordnung (MitID,ProNr,Istanteil,Plananteil) values
('146',46,0.999,0.7);

insert into Zuordnung (MitID,ProNr,Istanteil,Plananteil) values
('146',37,0.111,0.3);

insert into Zuordnung (MitID,ProNr,Istanteil,Plananteil) values
('106',46,0.111,0.1);

insert into Projekt (ProNr,Proname,Aufwand) values
(47,'Oracle-Prakt.',0);

--2 4
create procedure projA (@PNr int) as
declare @Proname char(15)
declare @LeiterID char(3)

print select ProNr,Proname,Aufwand,LeiterID,Nachname,Vorname from Projekt join Mitarbeiter on LeiterID = MitID where ProNr = @PNr

declare @MitID char (3)
declare @Nachname char(10)
declare @Vorname char(10)
declare @Beruf char(15)
declare @Plananteil float
declare @Istanteil float
declare @Abweichung float

declare PM cursor for select Mitarbeiter.MitID,Nachname,Vorname,Beruf,Plananteil,Istanteil,(Plananteil - Istanteil ) as 'Abweichung' from Mitarbeiter join Zuordnung on Mitarbeiter.MitID = Zuordnung.MitID where ProNr = @PNr
open PM

fetch PM into @MitID,@Nachname,@Vorname,@Beruf,@Plananteil,@Istanteil,@Abweichung
if(@@sqlstatus = 2)
begin 
    print 'Kein Mitarbeiter zugeteilt!'
    close PM
    return
end

while(@@sqlstatus = 0)
begin
    print 'MitID: %1! Nachname: %2! Vorname: %3! Beruf: %4! Plananteil: %5! Istanteil: %6! Abweichung: %7! ', @MitID,@Nachname,@Vorname,@Beruf,@Plananteil,@Istanteil,@Abweichung
    fetch PM into @MitID,@Nachname,@Vorname,@Beruf,@Plananteil,@Istanteil,@Abweichung
end

close PM
return



--2.5
select Nachname,Vorname,Ort,Proname from Mitarbeiter,Projekt where Mitarbeiter.MitID = Projekt.LeiterID;
select Nachname,Vorname,Ort,Proname from Mitarbeiter join Projekt on Mitarbeiter.MitID = Projekt.LeiterID;

select Mitarbeiter.MitID,Nachname,Vorname,Projekt.ProNr,Istanteil from Mitarbeiter,Projekt,Zuordnung
where Mitarbeiter.MitID = Zuordnung.MitID and Zuordnung.ProNr = Projekt.ProNr;
select Mitarbeiter.MitID,Nachname,Vorname,Projekt.ProNr,Istanteil from Mitarbeiter 
join Zuordnung on Mitarbeiter.MitID = Zuordnung.MitID 
join Projekt on Zuordnung.ProNr = Projekt.ProNr;

select Projekt.ProNr,Proname,Nachname,Vorname,Ort,Istanteil as 'Aufwand Leiter' from Projekt
left join Mitarbeiter on Mitarbeiter.MitID = LeiterID
left join Zuordnung on Projekt.ProNr = Zuordnung.ProNr and LeiterID = Zuordnung.MitID
where Projekt.ProNr in (select ProNr from Zuordnung group by ProNr having sum(Istanteil) >= 3);
select Projekt.ProNr,Proname,Nachname,Vorname,Ort,Istanteil as 'Aufwand Leiter' from Projekt,Mitarbeiter,Zuordnung
where (Mitarbeiter.MitID = LeiterID) and Projekt.ProNr = Zuordnung.ProNr and (LeiterID = Zuordnung.MitID) and Projekt.ProNr in (select ProNr from Zuordnung group by ProNr having sum(Istanteil) >= 3);

select Projekt.ProNr,Projekt.Proname,sum(Istanteil) as 'Summe Istanteile' 
from Projekt left join Zuordnung on Projekt.ProNr = Zuordnung.ProNr
group by Projekt.ProNr;

begin
declare @dummy float(8)
select @dummy = NULL
select Projekt.ProNr,Projekt.Proname,sum(Istanteil) as 'Summe Istanteile' 
from Projekt,Zuordnung where Projekt.ProNr = Zuordnung.ProNr
group by Projekt.ProNr
union 
select Projekt.ProNr,Projekt.Proname,@dummy as 'Summe Istanteile' 
from Projekt where ProNr not in (select ProNr from Zuordnung)
order by ProNr
end;

select Mitarbeiter.MitID,Nachname,Vorname,Ort,(1 - sum(Plananteil)) as 'Reserve'
from Mitarbeiter left join Zuordnung on Mitarbeiter.MitID = Zuordnung.MitID
group by Mitarbeiter.MitID;

begin
declare @dummy float(8)
select @dummy = NULL
select Mitarbeiter.MitID,Nachname,Vorname,Ort,(1 - sum(Plananteil)) as 'Reserve'
from Mitarbeiter,Zuordnung where Mitarbeiter.MitID = Zuordnung.MitID
group by Mitarbeiter.MitID
union
select Mitarbeiter.MitID,Nachname,Vorname,Ort,@dummy as 'Reserve'
from Mitarbeiter where Mitarbeiter.MitID not in (select MitID from Zuordnung)
order by Mitarbeiter.MitID
end;
--3
select * into Kopie_Mitarbeiter from Mitarbeiter;
sp_who s70228;
begin transaction
delete Kopie_Mitarbeiter
select * from Kopie_Mitarbeiter
rollback;
--Atomicy, Consistency, Isolation Durabily

sp_adduser s70228;
grant select on  Mitarbeiter to s70228;
revoke select on  Mitarbeiter to s70228;
grant select on Kopie_Mitarbeiter(MitID,Nachname) to s70228;
sp_helprotect Kopie_Mitarbeiter;
revoke select on Kopie_Mitarbeiter(MitID,Nachname) to s70228;
grant select on Kopie_Mitarbeiter to s70228

--4 I 1 
create default DD as 'Dresden';
sp_bindefault DD,'Mitarbeiter.Ort';

create default DIng as 'Dipl.-Ing.';
sp_bindefault DIng,'Mitarbeiter.Beruf';

alter table Mitarbeiter add constraint MitIDRange check (MitID like '[0-9][0-9][0-9]');

create rule eighthundred as (convert(int,@i) < 800 and convert(int,@i) > 100);
sp_bindrule eighthundred,'Mitarbeiter.MitID';

create rule relevantAdult as ((year(getdate()) - year(@i)) <= 60 and (year(getdate()) - year(@i)) >= 18);
sp_bindrule relevantAdult,'Mitarbeiter.Gebdat';

alter table Zuordnung add constraint realIst check (Istanteil <= 1.0);

-- 4 II 4.1
--a)
alter table Projekt add foreign key (LeiterID) references Mitarbeiter(MitID);

insert into Mitarbeiter (MitID,Nachname,Vorname,Gebdat,Telnr) 
values ('555','New Guy','Mr.','1987-06-05','2323');
insert into Projekt (ProNr,Proname,Beschreibung,Aufwand,LeiterID)
values (4242,'FNP','Fracking New Project',9001,'555');

update Projekt set LeiterID = '666' where ProNr = 4242;
update Mitarbeiter set MitID = '667' where MitID = '555';

--b)
delete Mitarbeiter where MitID = '555';

--c)
update Projekt set LeiterID = '146' where ProNr = 4242;
update Mitarbeiter set MitID = '667' where MitID = '555';
delete Mitarbeiter where MitID = '667';
--d)
insert into Projekt (ProNr,Proname,Beschreibung,Aufwand,LeiterID)
values (4342,'Frop','Fracking New Project',9001,'666');
--e)
insert into Projekt (ProNr,Proname,Beschreibung,Aufwand,LeiterID)
values (4342,'Frop','Fracking New Project',9001,NULL);


--4 III 5.1
create trigger Plananteil_Summe_1_per_Mitarbeiter on Zuordnung
for insert,update as
if update (Plananteil)
    begin
    if ((select count(count(inserted.MitID)) from inserted,Zuordnung 
    where inserted.MitID = Zuordnung.MitID and inserted.ProNr = Zuordnung.ProNr
    group by inserted.MitID having sum(inserted.Plananteil) > 1.0) > 0 )
        begin
        print 'Mitarbeiter darf kein Soll > 1.0 besitzen'
        rollback
        end
    end;
--a)
begin transaction
update Zuordnung set Plananteil = Plananteil + 0.3 where ProNr = 31
rollback;
--b) 
begin transaction
update Zuordnung set Plananteil = Plananteil + 0.4 where MitID = '105'
rollbacK;

--4 III 5.2
create trigger Abgeschlossenes_Projekt on Zuordnung
for delete,update as
update Projekt set LeiterID = NULL where ProNr in (select ProNr from deleted where ProNr not in (select ProNr from Zuordnung));

--a)
begin transaction
delete Zuordnung where ProNr = 36
select * from Projekt where ProNr = 36
rollback;
--b)
begin transaction
update Zuordnung set ProNr = 37 where ProNr = 35
select * from Projekt
rollback;

--4 III 6
create table Bprotokoll(
MitID char(3),Nutzer char(16),Zeit datetime,Beruf_alt char(15),Beruf_neu char(15)
);

create trigger Beruf_Proto on Mitarbeiter
for update  as
if update(Beruf)
    begin
    declare @MitID char(3)
    select @MitID = (select (inserted.MitID) from inserted,deleted
    where inserted.MitID = deleted.MitID)
    declare @Beruf_alt char(15)
    declare @Beruf_neu char(15)
    select @Beruf_alt = (select Beruf from deleted where MitID = @MitID)
    select @Beruf_neu = (select Beruf from inserted where MitID = @MitID)
    insert into Bprotokoll(Nutzer,Zeit,MitID,Beruf_alt,Beruf_neu)
    values (user_name(),getdate(),@MitID,@Beruf_alt,@Beruf_neu)
        end;

begin transaction
update Mitarbeiter set Beruf = 'Klugscheisser' where MitID = '146'
select * from Bprotokoll
rollback;

--PK(Nutzer,Zeit)

create trigger Beruf_Proto_Cascade on Mitarbeiter
for delete as
delete Bprotokoll where MitID in (select MitID from deleted);

begin transaction
update Mitarbeiter set Beruf = 'Klugscheisser' where MitID = '135'
delete Mitarbeiter where MitID = '135'
select * from Bprotokoll
rollback;
--Oracle
--1.3.
-- Wiedergabe von TABLE DDL für Objekt DB01.HERSTELLER nicht möglich, da DBMS_METADATA internen Generator versucht.
CREATE TABLE HERSTELLER 
(
  HSTNR VARCHAR2(10 BYTE) NOT NULL 
, NAME VARCHAR2(50 BYTE) NOT NULL 
, STRASSE VARCHAR2(50 BYTE) 
, PLZ VARCHAR2(5 BYTE) 
, ORT VARCHAR2(50 BYTE) 
, KONTAKTAUFNAHME DATE DEFAULT sysdate 
, CONSTRAINT PK_HERSTELLER PRIMARY KEY 
  (
    HSTNR 
  )
  ENABLE 
) 
CREATE UNIQUE INDEX PK_HERSTELLER ON HERSTELLER (HSTNR) 
Insert into HERSTELLER (HSTNR,NAME,STRASSE,PLZ,ORT,KONTAKTAUFNAHME) values ('134556','Magna Heiligenstadt','Fabrikstrasse 32','37308','Heiligenstadt',to_date('12.06.07','DD.MM.RR'));
Insert into HERSTELLER (HSTNR,NAME,STRASSE,PLZ,ORT,KONTAKTAUFNAHME) values ('588797','MAN','Ginsheimerstr. 2','65462','Ginsheim',to_date('01.01.11','DD.MM.RR'));


--1.5
insert into hersteller(hstnr,hstname,strasse,plz,ort) values ('693253','Tower Zwickau','Kopernikusstr. 60','08056','Zwickau')

--1.6
select name,plz,ort from hersteller order by plz

--1.7
select * from Hersteller where months_between(sysdate,kontaktaufnahme) < 60

--1.8











