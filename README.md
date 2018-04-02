# Lab-Maintenance-Database

All Scripts are for Oracle 11g<br />
I want to redo this project for either SQL Server or MySQL<br />
I don't exactly remember what each of the scripts did and will have to be investigated<br />

Table Descriptions:

![alt text](https://github.com/bluerosinneo/Lab-Maintenance-Database/blob/master/ER%20Diagram.png)

Manufacturer(<br />
ID,<br />
Name,<br />
Comments)<br />
Purpose is to keep track of the different manufacturer bodies that make the equipment in the facility.  ID is a primary key that is planned to be an auto increment integer, Name will be the name of the Manufacturer and will be a string, and Comments would be used to store any additional information and may be taken out

Model(<br />
ID,<br />
ManufacturerID,<br />
Name,<br />
Comments)<br />
Purpose is to keep track of all of the different models of particular equipment in the facility.  ID is a primary key that is planned to be an auto increment integer, ManufacturerID is a foreign key referencing the ID field of the Manufacturer table, Name will be a string of the model name, and Comments would be used to store any additional information and may be taken out

Group(<br />
ID,<br />
Name,<br />
Comments)<br />
Purpose of this table is to keep track of users groups who equipment is either assigned to or identify which user performed which maintenance task.  Examples would be different Labs, Administrators, Managers.   ID is a primary key that is planned to be an auto increment integer, Name is a string describing how the group is identified, and Comments would be used to store any additional information and may be taken out

User(<br />
ID,<br />
GroupID,<br />
Name,<br />
Comments)<br />
Purpose of this table is to keep track of all individual users who equipment is either assigned to or identify which user performed which maintenance task.  ID is a primary key that is planned to be an auto increment integer, Group ID is a foreign key referencing the Group table.  Name is a string describing how the user is identified, and Comments would be used to store any additional information and may be taken out

Item(<br />
ID,<br />
ModelID,<br />
UserID,<br />
Name,<br />
Comments)<br />
Purpose of this table is a representation of each physical piece of equipment in the facility.  This table efectivly creates a many to many relationship between the Model table and the Item table.  ID is a primary key that is planned to be an auto increment integer, ModelID is a foreign key referencing the Model table, UserID is a foreign key referencing the User table, Name will be a set length string representing a code such as P001, Comments would be used to store any additional information and may be taken out

Maintenance(<br />
ID,<br />
Name,<br />
FrequencyMonths,<br />
GraceMonths,<br />
GraceWeeks,<br />
Comments)<br />
Purpose of this table is to store all the types of maintenance that can be performed on items.  ID is a primary key that is planned to be an auto increment integer, Name will be a string describing the maintenance task, FrequencyMonths will be an integer representing in months how frequent a maintenance task should be done, GraceMonths will be an integer indicating how many months away from the FrequencyMonths is allowed, GraceWeeks will be an integer indication how many weeks away from the frequencyMonths is allowed (note that either GraceMonths or GraceWeeks should be Null but not both),  Comments would be used to store any additional information and may be taken out

ItemMaintenance(<br />
ID,<br />
ItemID,<br />
MaintenanceID,<br />
Comments)<br />
Purpose of this table is to create a many to many relationship between Maintenance and Item table.  This table will indicate which Maintenance should be done on each individual item.  ID is a primary key that is planned to be an auto increment integer, ItemID is a foreign key referencing the Item table, MaintenanceID is a foreign key referencing the maintenance table, Comments would be used to store any additional information and may be taken out

Date(<br />
ID,<br />
ItemMaintenanceID,<br />
UserID,<br />
Date,<br />
Comments)<br />
Purpose of this table is to keep track of dates that maintenance tasks were completed on.  ID is a primary key that is planned to be an auto increment integer, ItemMaintenanceID is a foreign key referencing the ItemMaintenance Table, UserID is a foreign key referencing the User table indicating which user performed the maintenance.  Date will represent the date that the maintenance was performed (the time will not be specified), Comments would be used to store any additional information and may be taken out
