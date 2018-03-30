--Queries

--Item & User for easy joining
drop view Item_User;
create view Item_User as
select i.ID ItemID, ModelID, UserID,u.name UserName, i.Name ItemName
from AAITEM i inner join AAUSER u
on i.UserID = u.ID;

--Item & Maintenance easy joining
drop view Item_Maintenance;
create view Item_Maintenance as
select im.ID ItemMaintenanceID, i.ID ItemID, main.ID MaintenanceID, i.Name ItemName,
main.Name MaintenanceName
from AAITEMMAINTENANCE im inner join AAMAINTENANCE main
on im.MaintenanceID = main.id
inner join AAITEM i
on im.ItemID = i.ID;

select *
from Item_Maintenance;

--view to look at items that have more than one dateperformed
drop view Maint_AtLeastOnce;
create view Maint_AtLeastOnce AS
select ItemName
from AADATE inner join Item_Maintenance
on AADATE.ItemMaintenanceID = Item_Maintenance.ItemMaintenanceID
group by ItemName
having Count(DatePerformed) >=1;

select *
from Maint_AtLeastOnce
order by ItemName;

--Manufacturer & Model easy joining
drop view Manufacturer_Model;
create view Manufacturer_Model as
select ma.ID ManufacturerID, mo.ID ModelID, ma.Name ManufacturerName, mo.Name ModelName
from AAMANUFACTURER ma inner join AAMODEL mo
on ma.ID = mo.ManufacturerID;

--Item Maintenance ItemMaintenance and date easy joining
drop view ItemMaintenance_Date;
create view ItemMaintenance_Date as
select im.id ItemMaintenanceID, im.ItemID ItemID, im.MaintenanceID MaintenanceID,
d.DatePerformed DatePerformed, main.FrequencyMonths FreqMonths, Main.GraceMonths GraceMonths
from AAITEMMAINTENANCE im inner join AADATE d
on im.id = d.ItemMaintenanceID
inner join AAMAINTENANCE main
on main.id = im.MaintenanceID;

--Item Maintenance joining
drop view Maintenance_Item;
create view Maintenance_Item as
select i.Name ItemName, m.ID MaintenanceID, m.Name MaintenanceName
from AAITEM i inner join AAITEMMAINTENANCE im
on i.id = im.ItemID
inner join AAMAINTENANCE m
on m.ID = IM.MaintenanceID;

--items that have the shortest time between requered maintenance
select distinct i.Name, FreqMonths
from ItemMaintenance_Date imd join AAITEM i
on imd.ItemID = i.ID
where FreqMonths in (select min(FreqMonths) from ItemMaintenance_Date);

--items that have the largest time between requered maintenance
select distinct i.Name, FreqMonths
from ItemMaintenance_Date imd join AAITEM i
on imd.ItemID = i.ID
where FreqMonths in (select max(FreqMonths) from ItemMaintenance_Date);

-- nice formatting that returns the last time maintenance was performed on
-- all items used by user Heim
select rpad(i.Name, 10, '.') Item, rpad(mo.Name, 40, '.') Model,
rpad(ma.Name, 13, '.') Manufacturer,
rpad(to_char(max(dateperformed), 'Month DD, YYYY'),30, '.') "Date of last maintenance"
from AAITEM i inner join AAMODEL mo
on i.ModelID = mo.ID
inner join AAMANUFACTURER ma
on ma.ID = MO.ManufacturerID
inner join ItemMaintenance_Date imd
on i.ID = imd.ItemID
where i.UserID = (select ID from AAUSER where NAME = 'Heim')
group by rpad(i.Name, 10, '.'), rpad(mo.Name, 40, '.'), rpad(ma.Name, 13, '.');



-- query that determins if maintenance has been done on an item or not
select Name, decode(ItemName, null, 'No Maintenance Done', 'Maintenance Done') "Maintenance Done?"
from AAITEM left outer join Maint_AtLeastOnce
on AAITEM.Name = Maint_AtLeastOnce.ItemName
order by Name;


--querry to return instances when dates of maintenence were within the frequency and window
select i.name Item, m.Name Maintenance, months_between(d1.DatePerformed, d2.DatePerformed) MonthBetween,
d2.DatePerformed Date1, d1.DatePerformed Date2
from ItemMaintenance_Date d1 inner join ItemMaintenance_Date d2
on d1.ItemMaintenanceID = d2.ItemMaintenanceID
inner join AAITEM i
on i.ID = d1.ItemID
inner join AAMAINTENANCE m
on m.id = d1.MaintenanceID
where months_between(d1.DatePerformed, d2.DatePerformed)>0
and months_between(d1.DatePerformed, d2.DatePerformed)<= (d1.FreqMonths + d2.GraceMonths); 

--stripping to get features of items
select distinct rtrim(ItemName, '0123456789')
from Maintenance_Item;

-- insert First
drop table AAITEMTYPE;
create table AAITEMTYPE(
Name varchar2(20),
ShortName varchar(2),
MaintenanceName varchar(50)
);

insert first
when ShortName = 'B' then
  into AAITEMTYPE values ('Balance', ShortName, MaintenanceName)
when ShortName = 'C' then
  into AAITEMTYPE values ('Centrifuge', ShortName, MaintenanceName)
when ShortName = 'EV' then
  into AAITEMTYPE values ('Evaporex', ShortName, MaintenanceName)
when ShortName = 'F' then
  into AAITEMTYPE values ('Freezer', ShortName, MaintenanceName)
when ShortName = 'FS' then
  into AAITEMTYPE values ('Flask Scrubber', ShortName, MaintenanceName)
when ShortName = 'P' then
  into AAITEMTYPE values ('Pipette', ShortName, MaintenanceName)
when ShortName = 'PX' then
  into AAITEMTYPE values ('RPipette', ShortName, MaintenanceName)
when ShortName = 'R' then
  into AAITEMTYPE values ('REMP', ShortName, MaintenanceName)
when ShortName = 'TV' then
  into AAITEMTYPE values ('TurboVap', ShortName, MaintenanceName)
select distinct rtrim(ItemName, '0123456789') ShortName, MaintenanceName
from Maintenance_Item
order by rtrim(ItemName, '0123456789');

--insert all
drop table AAITEMTYPEWITHKEY;
create table AAITEMTYPEWITHKEY(
Name varchar2(20),
ShortName varchar(2),
MaintenanceID number(38)
);

insert all
  into AAITEMTYPEWITHKEY values (Name, ShortName, MaintenanceID)
select it.Name, it.ShortName, m.ID MaintenanceID
from AAITEMTYPE it inner join AAMAINTENANCE m
on it.MaintenanceName = m.Name;

