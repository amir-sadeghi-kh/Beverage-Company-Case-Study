/*
Authored By: Amir H. Sadeghi
Authored On: 2022-11-23
Authored To: Project-ST555

Change Logs: 

Updated By: Amir H. Sadeghi
Updated on: 2022-11-29
Updated to: Project-ST555, Adding formats for product names

*/

* set libraries and options;
x "cd L:/st555/Data/BookData/BeverageCompanyCaseStudy/";
libname InputDS ".";
filename InputRaw ".";

x "cd L:/st555/Results";
libname Results "."; 

x "cd L:/st555/Data";
libname Formats ".";

x "cd S:/Exam";
libname Exam ".";

libname PopData access "L:\st555\Data\BookData\BeverageCompanyCaseStudy\2016Data.accdb"; 

options fmtsearch = (Formats Exam);
ods listing close;
ods trace on;

* Counties data, using access file;
DATA Exam.Counties; 
  set PopData.counties;
run;
libname PopData clear;

* NonColaSouth data, using formatted input;
DATA Exam.NonColaSouth;
  infile  InputRaw("Non-Cola--NC,SC,GA.dat") dlm = '09'X dsd firstobs = 7;
  length  productname $50 size $200 _date $20;
  input   stateFips 2.    
          countyFips 3.      
          productname $20. 
          size $10.
          @36 unitSize 3.  
          _date $10.
          unitssold;
run;

* EnergySouth data, using list-based input styles;
DATA Exam.EnergySouth;
  infile  InputRaw("Energy--NC,SC,GA.txt") dlm = '09'X dsd firstobs = 2;
  length  productname $50 size $200 _date $20;
  input   stateFips      
          countyFips       
          productname $  
          size $    
          unitSize  
          _date $   
          unitssold;
run;

* OtherSouth data, using list-based input styles;
DATA Exam.OtherSouth;
  infile  InputRaw("Other--NC,SC,GA.csv") dsd firstobs = 2;
  length  productname $50 size $200 _date $20;
  input   stateFips      
          countyFips       
          productname $  
          size $    
          unitSize  
          _date $   
          unitssold;
run;

* NonColaNorth data, using formatted input;
DATA Exam.NonColaNorth;
  infile  InputRaw("Non-Cola--DC-MD-VA.dat") dlm = '09'X dsd firstobs = 7;
  length  code $200 _date $20; 
  input   stateFips 2.    
          countyFips 3.      
          code $25. 
          _date $10.
          unitssold;
run;

* EnergyNorth data, using list-based input styles; 
DATA Exam.EnergyNorth;
  infile  InputRaw("Energy--DC-MD-VA.txt") dlm = '09'X dsd firstobs = 2;
  length  code $200 _date $20;
  input   stateFips      
          countyFips       
          code $  
          _date $  
          unitssold;
run;

* OtherNorth data, using list-based input styles; 
DATA Exam.OtherNorth;
  infile  InputRaw("Other--DC-MD-VA.csv") dsd firstobs = 2;
  length  code $200 _date $20;
  input   stateFips      
          countyFips       
          code $  
          _date $  
          unitssold;
run;

** Define formats;
* ProductName/Soda (Cola, Non-Cola)format is defined by Dr. Duggins, we use InputFM lib to use that;
* ProductName/Energy & ProductName/Others format;
PROC format library = Exam;
  value EnergyProductNameFormat
  1  = "Zip-Orange"
  2  = "Zip-Berry"
  3  = "Zip-Grape"
  4  = "Diet Zip-Orange"
  5  = "Diet Zip-Berry"
  6  = "Diet Zip-Grape"
  7  = "Big Zip-Berry"
  8  = "Big Zip-Grape"
  9  = "Diet Big Zip-Berry"
  10 = "Diet Big Zip-Grape"
  11 = "Mega Zip-Orange"
  12 = "Mega Zip-Berry"
  13 = "Diet Mega Zip-Orange"
  14 = "Diet Mega Zip-Berry";
  
  value OtherProductNameFormat
  1 = "Non-Soda Ades-Lemonade"
  2 = "Non-Soda Ades-Diet Lemonade"
  3 = "Non-Soda Ades-Orangeade"
  4 = "Non-Soda Ades-Diet Orangeade"
  5 = "Nutritional Water-Orange"
  6 = "Nutritional Water-Grape"
  7 = "Diet Nutritional Water-Orange"
  8 = "Diet Nutritional Water-Grape";
run;

* AllDrinks Data, Combine datasets;
DATA Exam.AllDrinks(drop = _:);
  * Set length for variable;
  length  region $8 
          productname $50 
          type $8 
          productCategory $30 
          productSubCategory $30
          flavor $30
          container $6
          size $200;

  set     Exam.NonColaSouth   (in = inNonColaSouth)
          Exam.EnergySouth    (in = inEnergySouth)
          Exam.OtherSouth     (in = inOtherSouth)
          InputDS.ColaNCSCGA  (in = inColaSouth)
          Exam.NonColaNorth   (in = inNonColaNorth)
          Exam.EnergyNorth    (in = inEnergyNorth)
          Exam.OtherNorth     (in = inOtherNorth)
          InputDS.ColaDCMDVA  (in = inColaNorth);

  * Define temporary variables (clean coding);
  _inSouth = inNonColaSouth + inEnergySouth + inOtherSouth + inColaSouth;
  _inNorth = inNonColaNorth + inEnergyNorth + inOtherNorth + inColaNorth;
  _inNonCola = inNonColaSouth + inNonColaNorth;
  _inEnergy = inEnergySouth + inEnergyNorth;
  _inOther = inOtherSouth + inOtherNorth;
  _inCola = inColaSouth + inColaNorth;

  * Define region;
  if _inSouth gt 0 then 
    region = "South";
  if _inNorth gt 0 then 
    region = "North";

  * Define date (Only for non SAS datasets);
  if _inCola eq 0 then 
    date = input(_date, ANYDTDTE20.);

  * Define product name;
  _productnumber = input(scan(code,2), 2.);
  if inNonColaNorth + inColaNorth gt 0 then
    productname = put(_productnumber, Prodnames.);
  else if inEnergyNorth gt 0 then
    productname = put(_productnumber, EnergyProductNameFormat.);
  else if inOtherNorth gt 0 then
    productname = put(_productnumber, OtherProductNameFormat.);
  else
    productname = propcase(productname);

  * Define type;
  if index(productname, "Diet") gt 0 then 
    type = "Diet";
  else
    type = "Non-Diet";

  * Define product category;
  if _inNonCola gt 0 then 
    productCategory = "Soda: Non-Cola";
  else if _inEnergy gt 0 then 
    productCategory = "Energy";
  else if _inCola gt 0 then 
    productCategory = "Soda: Cola";
  else if _inOther gt 0 then do;
    if INDEX(productname,"Non-Soda") gt 0 then
      productCategory = "Non-Soda Ades";
    else 
      productCategory = "Nutritional Water";
  end;

  * Define product subcategory (Only energy drinks have subcategory);
  if _inEnergy gt 0 then do;
    if index(productname, "Big Zip") gt 0 then 
      productSubCategory = "Big Zip";
    else if index(productname, "Mega Zip") gt 0 then 
      productSubCategory = "Mega Zip";
    else 
      productSubCategory = "Zip";
  end;

  * Define flavor; 
  if _inEnergy gt 0 then 
    flavor = input(substr(productname,index(productname, "-")+1), $30.);
  else do;
    flavor = productname;
    flavor = tranwrd(flavor,'Non-Soda Ades-','');
    flavor = tranwrd(flavor,'Nutritional Water-','');
    flavor = tranwrd(flavor,'Diet','');
    flavor = strip(flavor);
  end;

  * Define Size; 
  if _inNorth gt 0 then 
    size = input(catx(" ", scan(code, 3), scan(code,4)), $200.);
  else 
    size = lowcase(size);
  ** then make all either same oz or liter;
  size = tranwrd(size, 'ounces', 'oz');
  size = tranwrd(size, 'liters', 'liter');
  if ((index(size, "liter") eq 0) and (index(size, "l"))) gt 0 then
    size = tranwrd(size, "l", 'liter');

  * Define container;
  if size in ("1 liter", "2 liter", "20 oz") then 
    container = 'Bottle';
  else 
    container = 'Can';

  * Define Unit Size (Unit Size is not asked in the project documentation for "AllDrinks" but we need it for "AllData");
  if _inNorth gt 0 then
    unitsize = input(scan(code, -1),BEST12.) ;
 
run;

*Sort _inA (AllDrinks) for merge;
PROC sort data = Exam.AllDrinks out = Exam.AllDrinksSort;
  by StateFips CountyFips;
run;

*Sort _inB (Counties) for merge; 
PROC sort data = Exam.Counties (drop = region rename = (state=StateFips county=CountyFips)) out = Exam.CountiesSort;
  by StateFips CountyFips;
run;

* AllData;
DATA Exam.AllData;
  merge Exam.AllDrinksSort(in = inA) Exam.CountiesSort (in = inB);
  by StateFips CountyFips;
  * Define salesPerThousand;
  salesPerThousand = 1000*unitssold/((popestimate2016 + popestimate2017)/2);
  if (inA eq 1) then output Exam.AllData; * Left join;

  attrib
    stateName  label = "State Name"
    stateFips  label = "State FIPS"
    countyName label = "County Name"
    countyFips label = "County FIPS"
    region     label = "Region"
    popestimate2016 format = COMMA10. label = "Estimated Population in 2016"
    popestimate2017 format = COMMA10. label = "Estimated Population in 2017"
    productname  label = "Beverage Name"
    type  label = "Beverage Type"
    flavor  label = "Beverage Flavor"
    productCategory  label = "Beverage Category"
    productSubCategory   label = "Beverage Sub-Category"
    size  label = "Beverage Volume"
    unitsize format =BEST12. label = "Beverage Quantity"
    container label = "Beverage Container"
    date format = DATE9. label = "Sale Date" 
    unitssold format = COMMA7. label = "Units Sold"
    salesPerThousand format = 7.4 label="Sales per 1,000";
run;

* Data for Activity 3.6;
** Output 3.6;
PROC means data = Exam.AllData(where = ( (productname in ("Diet Nutritional Water-Grape", "Diet Nutritional Water-Orange", "Nutritional Water-Grape", "Nutritional Water-Orange")) & (unitSize EQ 1) & (region EQ "South") )) nonobs mean median maxdec = 2;
  class productname;
  var unitssold;
  ods output summary = Exam.Data_Activity3_6; 
run;

* Data for Activity 4.4;
** Sort for PROC means;
PROC sort data = Exam.AllData out = Exam.AllDataSortByRegionType;
  by region type descending unitssold;
run; 

** Output 4.4;
PROC means data = Exam.AllDataSortByRegionType(where = ((productCategory EQ "Soda: Cola") & (size EQ "20 oz") & (container EQ "Bottle") & (unitSize EQ 1))) nonobs p25 p75;
  by region type;
  class Date;
  var unitssold;
  ods output summary = Exam.Data_Activity4_4;
run;

* Output Optional Activity;
PROC sort data=Exam.AllDrinks(keep = productname type productCategory productSubCategory flavor container size) out=Exam.Data_OptionalActivity NODUPKEY;
    by productCategory productSubCategory productname type container flavor size;
run;

* Data for Activity 5.5;
** Output 5.5;
PROC means data = Exam.AllDataSortByStateType(where = ( (stateName in ("South Carolina", "North Carolina" )) & (month(date) EQ 8) & (flavor EQ "Cola") & (size EQ "12 oz") & (unitSize EQ 1))) nonobs sum;
  by type;
  class Date stateName;
  var unitssold;
  ods output summary = Exam.Data_Activity5_5;
run;

* Close the trace and quit; 
ods trace off;
ods listing;
quit;












