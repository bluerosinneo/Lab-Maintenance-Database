# Lab-Maintenance-Database

All Scripts are for Oracle 11g
I want to redo this project for either SQL Server or MySQL
I don't exactly remember what each of the scripts did and will have to be investigated

Table Descriptions:

![alt text](https://github.com/bluerosinneo/Lab-Maintenance-Database/blob/master/ER%20Diagram.png)

Manufacturer (
ID,
Name
Comments)
Purpose is to keep track of the different manufacturer bodies that make the equipment in the facility.  ID is a primary key that is planned to be an auto increment integer, Name will be the name of the Manufacturer and will be a string, and Comments would be used to store any additional information and may be taken out

Model(
ID,
ManufacturerID,
Name,
Comments)
Purpose is to keep track of all of the different models of particular equipment in the facility.  ID is a primary key that is planned to be an auto increment integer, ManufacturerID is a foreign key referencing the ID field of the Manufacturer table, Name will be a string of the model name, and Comments would be used to store any additional information and may be taken out

Group(
ID,
Name,
Comments)
Purpose of this table is to keep track of users groups who equipment is either assigned to or identify which user performed which maintenance task.  Examples would be different Labs, Administrators, Managers.   ID is a primary key that is planned to be an auto increment integer, Name is a string describing how the group is identified, and Comments would be used to store any additional information and may be taken out


 
User(
ID
GroupID
Name,
Comments)
Purpose of this table is to keep track of all individual users who equipment is either assigned to or identify which user performed which maintenance task.  ID is a primary key that is planned to be an auto increment integer, Group ID is a foreign key referencing the Group table.  Name is a string describing how the user is identified, and Comments would be used to store any additional information and may be taken out

Item(
ID,
ModelID,
UserID,
Name,
Comments)
Purpose of this table is a representation of each physical piece of equipment in the facility.  This table efectivly creates a many to many relationship between the Model table and the Item table.  ID is a primary key that is planned to be an auto increment integer, ModelID is a foreign key referencing the Model table, UserID is a foreign key referencing the User table, Name will be a set length string representing a code such as P001, Comments would be used to store any additional information and may be taken out


Maintenance(
ID,
Name,
FrequencyMonths,
GraceMonths,
GraceWeeks,
Comments)
Purpose of this table is to store all the types of maintenance that can be performed on items.  ID is a primary key that is planned to be an auto increment integer, Name will be a string describing the maintenance task, FrequencyMonths will be an integer representing in months how frequent a maintenance task should be done, GraceMonths will be an integer indicating how many months away from the FrequencyMonths is allowed, GraceWeeks will be an integer indication how many weeks away from the frequencyMonths is allowed (note that either GraceMonths or GraceWeeks should be Null but not both),  Comments would be used to store any additional information and may be taken out


 
ItemMaintenance(
ID,
ItemID,
MaintenanceID,
Comments)
Purpose of this table is to create a many to many relationship between Maintenance and Item table.  This table will indicate which Maintenance should be done on each individual item.  ID is a primary key that is planned to be an auto increment integer, ItemID is a foreign key referencing the Item table, MaintenanceID is a foreign key referencing the maintenance table, Comments would be used to store any additional information and may be taken out


Date(
ID,
ItemMaintenanceID,
UserID,
Date,
Comments)
Purpose of this table is to keep track of dates that maintenance tasks were completed on.  ID is a primary key that is planned to be an auto increment integer, ItemMaintenanceID is a foreign key referencing the ItemMaintenance Table, UserID is a foreign key referencing the User table indicating which user performed the maintenance.  Date will represent the date that the maintenance was performed (the time will not be specified), Comments would be used to store any additional information and may be taken out

Relationships:

Manufacture to Model: One to Many
Group to User: One to Many
Model to Item: One to Many
User to Item: One to Many
Model to User: Many to Many (through the Item table)
Item to Item Maintenance: One to Many
Maintenance to ItemMaintenance: One to Many
Item to Maintenance: Many to Many (through the ItemMaintenance table)
ItemMaintenance to Date: One to Many
User to Date: One To Many
ItemMaintenance to User: Many to Many (through the Date table) (note the owner of the item might not perform the actual maintenance on the item)

