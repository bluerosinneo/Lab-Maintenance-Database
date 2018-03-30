-- create Tables


/*
Create Table Section
*/


--start drop table section
drop table AADATE;
drop table AAITEMMAINTENANCE;
drop table AAMAINTENANCE;
drop table AAITEM;
drop table AAMODEL;
drop table AAMANUFACTURER;
drop table AAUSER;
DROP TABLE AAOVERDUEREPORT;
DROP Table AADEVIATION;
--end drop talbe section

-- create AAMANUFACTURER
create table AAMANUFACTURER(
ID number(38) NOT NULL,
Name VARCHAR2(50) NOT NULL,
constraint AAMANUFACTURER_PK primary key (ID),
constraint AAMANUFACTURER_UN unique (Name)
);

-- create AAMODEL
create table AAMODEL(
ID number(38) NOT NULL,
ManufacturerID number(38) NOT NULL,
Name varchar2(50) NOT NULL,
ModelType varchar2(2) NOT NULL,
constraint AAMODEL_PK primary key (ID),
constraint AAMODEL_FK foreign key (ManufacturerID) references AAMANUFACTURER(ID)
);

-- create AAUSER
create table AAUSER(
ID number(38) NOT NULL,
Name varchar2(50) NOT NULL,
constraint AAUSER_PK primary key (ID),
constraint AAUSER_UN unique (Name)
);

-- create AAITEM
create table AAITEM(
ID number(38) NOT NULL,
ModelID number(38) NOT NULL,
UserID number(38) NOT NULL,
Name varchar2(5) NOT NULL,
constraint AAITEM_PK primary key (ID),
constraint AAITEM_FK1 foreign key (ModelID) references AAMODEL(ID),
constraint AAITEM_FK2 foreign key (UserID) references AAUSER(ID)
);

create index index_ItemName
on AAITEM(Name);

-- create AAMAINTENANCE
create table AAMAINTENANCE(
ID number(38) NOT NULL,
Name varchar2(50) NOT NULL,
Description varchar2(100) NOT NULL,
FrequencyMonths number(3) NOT NULL,
GraceMonths number(2) NOT NULL,
ModelType varchar2(2) NOT NULL,
constraint AAMAINTENANCE primary key (ID),
constraint AAMAINTENANCE_UN unique (Name),
constraint FrequencyGrace_CK check (GraceMonths<=FrequencyMonths)
);

-- create AAITEMMAINTENANCE
create table AAITEMMAINTENANCE(
ID number(38) NOT NULL,
ItemID number(38) NOT NULL,
MaintenanceID number(38) NOT NULL,
constraint AAITEMMAINTENANCE_PK primary key (ID),
constraint AAITEMMAINTENANCE_FK1 foreign key (ItemID) references AAITEM(ID),
constraint AAITEMMAINTENANCE_FK2 foreign key (MaintenanceID) references AAMAINTENANCE(ID)
);

-- create Date
create table AADATE(
ID number(38) NOT NULL,
ItemMaintenanceID number(38) NOT NULL,
DatePerformed Date NOT NULL,
constraint AADATE_PK primary key (ID),
constraint AADATE_FK foreign key (ItemMaintenanceID) references AAITEMMAINTENANCE(ID)
);

create table AAOVERDUEREPORT(
ItemID number(38) NOT NULL,
MaintenanceID number(38) NOT NULL,
DaysOverDue number(4) NOT NULL,
DateOfReport Date NOT NULL
);

create table AADEVIATION(
ItemID number(38) NOT NULL,
MaintenanceID number(38) NOT NULL,
DaysOverDue number(4) NOT NULL,
DateOfNewMaintenance Date NOT NULL
);


/*
End Create Tables
*/


-- create sequences block
drop sequence ManufacturerID;
drop sequence ModelID;
drop sequence UserID;
drop sequence ItemID;
drop sequence MaintenanceID;
drop sequence ItemMaintenanceID;
drop sequence DateID;
create sequence ManufacturerID increment by 1 start with 1;
create sequence ModelID increment by 1 start with 1;
create sequence UserID increment by 1 start with 1;
create sequence ItemID increment by 1 start with 1;
create sequence MaintenanceID increment by 1 start with 1;
create sequence ItemMaintenanceID increment by 1 start with 1;
create sequence DateID increment by 1 start with 1;


create or replace trigger "Manufacturer_Insert"
before insert on AAMANUFACTURER
for each row
begin
if :new.ID is null then
select ManufacturerID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "Manufacturer_Insert" enable;

create or replace trigger "Model_Insert"
before insert on AAMODEL
for each row
begin
if :new.ID is null then
select ModelID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "Model_Insert" enable;

create or replace trigger "User_Insert"
before insert on AAUSER
for each row
begin
if :new.ID is null then
select UserID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "User_Insert" enable;

create or replace trigger "Item_Insert"
before insert on AAITEM
for each row
begin
if :new.ID is null then
select ItemID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "Item_Insert" enable;

create or replace trigger "Maintenance_Insert"
before insert on AAMAINTENANCE
for each row
begin
if :new.ID is null then
select MaintenanceID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "Maintenance_Insert" enable;


create or replace trigger "ItemMaintenance_Insert"
before insert on AAITEMMAINTENANCE
for each row
begin
if :new.ID is null then
select ItemMaintenanceID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "ItemMaintenance_Insert" enable;

create or replace trigger "Date_Insert"
before insert on AADATE
for each row
begin
if :new.ID is null then
select DateID.NextVal into :new.ID from dual;
end if;
end;
/
alter trigger "Date_Insert" enable;

--trigger to generate maintenance item records automatically when items are inserted into Item table
create or replace trigger ITEM_MAINTENANCE_CREATION
after insert on AAITEM
for each row
declare
cursor itemid_maintid_cursor is
  select :new.ID ItemID, m.id MaintID 
  from AAMAINTENANCE m
  where m.ModelType = substr(:new.Name, 0,2);
itemid_maintid_val itemid_maintid_cursor%ROWTYPE;
begin
open itemid_maintid_cursor;
loop
  fetch itemid_maintid_cursor into itemid_maintid_val;
  exit when itemid_maintid_cursor%NOTFOUND;
  insert into AAITEMMAINTENANCE (ID, ItemID, MaintenanceID)
    values (NULL, itemid_Maintid_val.ItemID, itemid_Maintid_val.MaintID);
end loop;
close itemid_maintid_cursor;
end;
/
alter trigger "ITEM_MAINTENANCE_CREATION" enable;

create or replace trigger Deviation_Creation
before insert on AADATE
for each row
declare
cursor Dev_cursor is
  select im.ItemID ItemID, im.MaintenanceID MaintID,m.FrequencyMonths Freq,
    max(d.DatePerformed) mday
  from AAITEMMAINTENANCE im inner join AADATE d
  on im.ID = d.ITEMMAINTENANCEID
  inner join AAMAINTENANCE m
  on im.MaintenanceID=m.ID
  where d.ItemMaintenanceID = :new.ItemMaintenanceID
  group by im.ItemID, im.MaintenanceID, m.frequencyMonths;
Dev_val Dev_cursor%ROWTYPE;

freq number(4);
OverNumber number(4);
begin
open Dev_cursor;
loop
  fetch Dev_cursor into Dev_val;
  exit when Dev_cursor%NOTFOUND;
  freq:=1;
  OverNumber := (:new.DatePerformed-Dev_val.mday)-(Dev_val.Freq+1)*30;
  if (OverNumber>0)
  then
    insert into AADEVIATION
      values (Dev_val.ItemID, Dev_Val.MaintID, OverNumber, :new.DatePerformed);
  end if;
end loop;
freq:=1;
end;
/
alter trigger Deviation_Creation enable;



select ID from AAITEMMAINTENANCE where ItemID =82 and MaintenanceID = 6;

insert into AAMANUFACTURER values (NULL,'Mettler Toledo');
insert into AAMANUFACTURER values (NULL,'Beckman');
insert into AAMANUFACTURER values (NULL,'Thermo Scientific');
insert into AAMANUFACTURER values (NULL,'GeneVac');
insert into AAMANUFACTURER values (NULL,'Revco');
insert into AAMANUFACTURER values (NULL,'Fisher Scientific');
insert into AAMANUFACTURER values (NULL,'Brand Tech');
insert into AAMANUFACTURER values (NULL,'Eppendorf');
insert into AAMANUFACTURER values (NULL,'Rainin');

insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Mettler Toledo'),'Pan Balance','BA');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Mettler Toledo'),'Analytical Balance','BA');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Mettler Toledo'),'Micro Balance','BA');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Beckman'),'Table Centrifuge','CE');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Beckman'),'Ultra Centrifuge','CE');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Thermo Scientific'),'Table Centrifuge','CE');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Thermo Scientific'),'Ultra Centrifuge','CE');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='GeneVac'),'TurboVap','EV');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Revco'),'Low Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Revco'),'Mid Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Revco'),'Ulta Low Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Fisher Scientific'),'Low Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Fisher Scientific'),'Mid Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Fisher Scientific'),'Ulta Low Freezer','FR');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Brand Tech'),'Flask Scrubber','FS');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Eppendorf'),'MicroFoot 2','PI');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Eppendorf'),'MicroFoot 10','PI');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Eppendorf'),'MicroFoot 100','PI');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Rainin'),'StolenFoot 2','PI');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Rainin'),'StolenFoot 10','PI');
insert into AAMODEL values (NULL, (select ID from AAMANUFACTURER where Name ='Rainin'),'StolenFoot 100','PI');

insert into AAUSER values (NULL,'Disposed');
insert into AAUSER values (NULL,'Decommissioned');
insert into AAUSER values (NULL,'Sparks');
insert into AAUSER values (NULL,'Brown');
insert into AAUSER values (NULL,'Finch');
insert into AAUSER values (NULL,'Brooks');
insert into AAUSER values (NULL,'Stringer');
insert into AAUSER values (NULL,'Simon');
insert into AAUSER values (NULL,'Dwulet');
insert into AAUSER values (NULL,'Reveles');
insert into AAUSER values (NULL,'Lowery');
insert into AAUSER values (NULL,'Smith');
insert into AAUSER values (NULL,'Woodward');
insert into AAUSER values (NULL,'Staton');
insert into AAUSER values (NULL,'Felke');
insert into AAUSER values (NULL,'Weber');
insert into AAUSER values (NULL,'Heim');
insert into AAUSER values (NULL,'Hieronymus');

insert into AAMAINTENANCE values (NULL,'Balance Annual','Calibration of Balance',12,1,'BA');
insert into AAMAINTENANCE values (NULL,'Centrifuge Quarterly','Clean rotor and rotor chamber,  Lubricate drive shaft',4,1,'CE');
insert into AAMAINTENANCE values (NULL,'Centrifuge Annual','Check temperature and RPMs',12,1,'CE');
insert into AAMAINTENANCE values (NULL,'Evaporex Quarterly','Verify each block temperature',4,1,'EV');
insert into AAMAINTENANCE values (NULL,'Freezer Semi-Annual','Defrost as needed',6,1,'FR');
insert into AAMAINTENANCE values (NULL,'Freezer Quarterly','Coil and filter cleaning',3,1,'FR');
insert into AAMAINTENANCE values (NULL,'Freezer Tri-Annual','Replace alarm battery',36,1,'FR');
insert into AAMAINTENANCE values (NULL,'Flask Scrubber Monthly','Thorough cleaning of inside and all parts.',3,1,'FS');
insert into AAMAINTENANCE values (NULL,'Verification','Verification Pipette In House',12,1,'PI');
insert into AAMAINTENANCE values (NULL,'Calibration','Calibration of Pipette',12,1,'PI');


create or replace procedure GENERATE_ITEMS (n IN number)
as
ModelID number(38); -- to store random ModelID
ModelCap number(38); -- use for ID selection
UserID number(38); -- to store random UserID
UserCap number(38); -- use for id selection
begin
  select to_number(count(*)) into ModelCap from AAMODEL;
  select to_number(count(*)) into UserCap from AAUSER;
  for i in 1..n
  loop

    ModelID := round(dbms_random.value(1, ModelCap));
    UserID := round(dbms_random.value(1, UserCap));
    
    insert into AAITEM
    values (NULL, ModelID, UserID, (select modeltype from AAMODEL where id=ModelID) || ltrim(to_char(i,'000')));
  end loop;
end;
/


exec GENERATE_ITEMS(100);

select ID, getitemidname(ItemID) ItemName, getMaintenanceIDName(MaintenanceID) MaintName
from AAITEMMAINTENANCE
order by ItemName, MaintName;

select im.id ItMaID, m.FrequencyMonths Freq
from AAMAINTENANCE m inner join AAITEMMAINTENANCE im
on m.ID = im.MaintenanceID;

create or replace procedure GENERATE_DATE (year IN number)
as
cursor ItMaID_Freq_cursor is
  select im.id ItMaID, m.FrequencyMonths Freq
  from AAMAINTENANCE m inner join AAITEMMAINTENANCE im
  on m.ID = im.MaintenanceID;
ItMaID_Freq_val ItMaID_Freq_cursor%ROWTYPE;
fdays number(38);
tdays number(38);
HoldDays number(38);
CurDateNum number(38);
DateInsert date;
begin

open ItMaID_Freq_cursor;
loop
  fetch ItMaID_Freq_cursor into ItMaID_Freq_val;
  exit when ItMaID_Freq_cursor%NOTFOUND;
  fdays := (ItMaID_Freq_val.Freq)*30;
  tdays := 365*year;
  CurDateNum := to_char(sysdate,'J');
  
  HoldDays := round(dbms_random.value(1,(fdays+37)));
  tdays := tdays - HoldDays;
  curDateNum := CurDateNum - HoldDays;
  DateInsert := to_date(CurDateNum,'J');
  insert into AADATE(ID,ItemMaintenanceID,DatePerformed)
    values (NULL, ItMaID_Freq_val.ItMaID,DateInsert);
  --before loop
  fdays := fdays - 37;
  while (tdays > 0)
  loop
    HoldDays := round(dbms_random.value(fdays,(fdays+74)));
    tdays := tdays - HoldDays;
    curDateNum := CurDateNum - HoldDays;
    DateInsert := to_date(CurDateNum,'J');
    insert into AADATE(ID,ItemMaintenanceID,DatePerformed)
      values (NULL, ItMaID_Freq_val.ItMaID,DateInsert);
  end loop;
end loop;
close ItMaID_Freq_cursor;
end;
/

delete from AADATE;
exec GENERATE_DATE(3);

select im.ID ItMaID, m.Name Des, d.ItemMaintenanceID ItMaintID, d.DatePerformed D
from AADATE d inner join AAITEMMAINTENANCE im
on d.ItemMaintenanceID = im.ID
inner join AAMAINTENANCE m
on im.MaintenanceID = m.ID
order by ItMaintID, D;


select im.ItemID ItemID, im.MaintenanceID MaintID, max(d.DatePerformed)
from AAITEMMAINTENANCE im inner join AADATE d
on im.ID = d.ITEMMAINTENANCEID
where im.ID in ( 
select ID
from AAITEMMAINTENANCE
minus
select distinct im.ID
from AADATE d inner join AAITEMMAINTENANCE im
on d.ItemMaintenanceID = im.ID
inner join AAMAINTENANCE m
on im.MaintenanceID = m.ID
where (((m.FrequencyMonths+1)*30)-trunc(sysdate - d.DatePerformed)) >=0
)
group by im.ItemID, im.MaintenanceID;


select MaintenanceID MaintID, ItemID
from AAITEMMAINTENANCE
minus
select distinct m.ID MaintID, im.ItemID ItemID
from AADATE d inner join AAITEMMAINTENANCE im
on d.ItemMaintenanceID = im.ID
inner join AAMAINTENANCE m
on im.MaintenanceID = m.ID
where (((m.FrequencyMonths+1)*30)-trunc(sysdate - d.DatePerformed)) >=0;


create or replace procedure Generate_Overdue
as
cursor out_of_comp_cursor is
  select im.ItemID ItemID, im.MaintenanceID MaintID, max(d.DatePerformed) mday
  from AAITEMMAINTENANCE im inner join AADATE d
  on im.ID = d.ITEMMAINTENANCEID
  where im.ID in ( 
  select ID
  from AAITEMMAINTENANCE
  minus
  select distinct im.ID
  from AADATE d inner join AAITEMMAINTENANCE im
  on d.ItemMaintenanceID = im.ID
  inner join AAMAINTENANCE m
  on im.MaintenanceID = m.ID
  where (((m.FrequencyMonths+1)*30)-trunc(sysdate - d.DatePerformed)) >=0
  )
  group by im.ItemID, im.MaintenanceID;
out_of_comp_val out_of_comp_cursor%ROWTYPE;
begin


open out_of_comp_cursor;
loop
  fetch out_of_comp_cursor into out_of_comp_val;
  exit when out_of_comp_cursor%NOTFOUND;
  insert into AAOVERDUEREPORT(ItemID, MaintenanceID, DaysOverDue, DateOfReport)
    values (out_of_comp_val.ItemId, out_of_comp_val.MaintID, 
      GetNumberDaysOverdue(out_of_comp_val.mday,out_of_comp_val.MaintID), sysdate);
  
end loop;
close out_of_comp_cursor;
end;
/

--delete from AAOVERDUEREPORT;
--exec Generate_Overdue;

select * from AAOVERDUEREPORT;

--insert into AADATE 
--values (NULL,(select ID from AAITEMMAINTENANCE where ItemID =50 and MaintenanceID = 9), sysdate);

select * from AADEVIATION;