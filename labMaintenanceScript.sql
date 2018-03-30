


--functions (1)
create or replace function GetItemIDName (IDin IN number)
  return varchar2
  is
  NameOut varchar2(5);
  begin
  select Name into NameOut from AAITEM where ID=IDin;
  return NameOut;
end;
/

--functions (2)
create or replace function GetMaintenanceIDName (IDin IN number)
  return varchar2
  is
  NameOut varchar2(50);
  begin
  select Name into NameOut from AAMAINTENANCE where ID=IDin;
  return NameOut;
end;
/

--functions (3)
create or replace function GetUserIDName (IDin IN number)
  return varchar2
  is
  NameOut varchar2(50);
  begin
  select Name into NameOut from AAUser where ID=IDin;
  return NameOut;
end;
/

--functions (4)
create or replace function GetModelIDName (IDin IN number)
  return varchar2
  is
  NameOut varchar2(50);
  begin
  select Name into NameOut from AAMODEL where ID=IDin;
  return NameOut;
end;
/

--functions (5)
create or replace function GetManufacturerIDName (IDin IN number)
  return varchar2
  is
  NameOut varchar2(50);
  begin
  select Name into NameOut from AAMANUFACTURER where ID=IDin;
  return NameOut;
end;
/

--function (6)
create or replace function GetNumberDaysOverdue (OverDate IN date, MaintID IN number)
return number
is
OverNumber number(4);
freq number(2);
begin
  select (frequencymonths) into freq from AAMAINTENANCE where id = MaintID;
  OverNumber := trunc((sysdate - OverDate))-((freq+1)*30);
  return OverNumber;
end;
/

select (frequencymonths+1)
from AAMAINTENANCE
where id = 1;

--test GetItemIDName() & GetMaintenanceIDname()
select ID , GetItemIDName(ItemID) ItemName, 
GetMaintenanceIDName(MaintenanceID) MaintName from AAITEMMAINTENANCE
order by ItemName;

--test GetUserIDName() GetUserIDName
select ID, GetModelIDName(ModelID) ModelName, GetUserIDName(UserID) UserName from AAITEM;

--test GetManufacturerIdName
select ID, getManufacturerIDName(ManufacturerID) ManufacturerName, Name from AAMODEL;

--Procedures 
--select TO_CHAR(sysdate, 'j') from dual;


create or replace package Compliance_SUBPROGRAMS
as
  function GetNumberDaysOverdue (OverDate IN date, MaintID IN number)return number;
  procedure Generate_Overdue;
end Compliance_SUBPROGRAMS;
/

create or replace package body Compliance_SUBPROGRAMS
as
function GetNumberDaysOverdue (OverDate IN date, MaintID IN number)
return number
is
OverNumber number(4);
freq number(2);
begin
  select (frequencymonths) into freq from AAMAINTENANCE where id = MaintID;
  OverNumber := trunc((sysdate - OverDate))-((freq+1)*30);
  return OverNumber;
end GetNumberDaysOverdue;

procedure Generate_Overdue
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
end Generate_Overdue;
end Compliance_SUBPROGRAMS;
/

--call Compliance_SUBPROGRAMS.Generate_Overdue();

