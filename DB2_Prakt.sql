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

--2.5
select Nachname,Vorname,Ort,Proname from Mitarbeiter,Projekt where Mitarbeiter.MitID = Projekt.LeiterID;
select Nachname,Vorname,Ort,Proname from Mitarbeiter join Projekt on Mitarbeiter.MitID = Projekt.LeiterID;

select Mitarbeiter.MitID,Nachname,Vorname,Projekt.ProNr,Istanteil from Mitarbeiter,Projekt,Zuordnung
where Mitarbeiter.MitID = Zuordnung.MitID and Zuordnung.ProNr = Projekt.ProNr;
select Mitarbeiter.MitID,Nachname,Vorname,Projekt.ProNr,Istanteil from Mitarbeiter 
join Zuordnung on Mitarbeiter.MitID = Zuordnung.MitID 
join Projekt on Zuordnung.ProNr = Projekt.ProNr;

select Projekt.ProNr,Proname,Nachname,Vorname,Ort,Istanteil from Zuordnung
join Projekt on Projekt.ProNr = Zuordnung.ProNr
join Mitarbeiter on Mitarbeiter.MitID = Projekt.LeiterID
group by Zuordnung.ProNr
having sum(Istanteil) >= 3; --TODO
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
alter table Projekt add foreign key (LeiterID) references Mitarbeiter(MitID);

