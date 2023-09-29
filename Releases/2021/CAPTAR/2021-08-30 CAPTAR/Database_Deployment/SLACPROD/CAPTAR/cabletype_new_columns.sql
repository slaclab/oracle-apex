--cabletype column is varchar2(15) only.
--We will need to increase it everywhere else.

alter table cabletyp add (
manufacturer_cd	  varchar2(2),
sig_type	varchar2(25),
cabletype_type	varchar2(25),
rating1		varchar2(25),
rating2		varchar2(25),
awg		varchar2(25),		
outer_diameter	varchar2(25),
weight		varchar2(25),
insulation	varchar2(25),	
max_temp	varchar2(25),
addnl_data	varchar2(30),
price		number,
xsect_area	varchar2(25),
cable_factor	varchar2(25),
power_level	varchar2(25),
zoneclass	varchar2(25),
drumsize	varchar2(25),
part_num	varchar2(25),
max_length	varchar2(25));

alter table cabletyp modify (
jacket		varchar2(12),
manufacture	varchar2(50),
cabdesc		varchar2(1000)
);

alter table cabletyp_jn modify (
old_jacket		varchar2(12),
new_jacket		varchar2(12),
old_manufacture		varchar2(50),
new_manufacture		varchar2(50),
old_cabdesc		varchar2(1000),
new_cabdesc		varchar2(1000)
);