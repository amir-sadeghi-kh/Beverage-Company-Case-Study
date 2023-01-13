/*
Authored By: Amir H. Sadeghi
Authored On: 2022-12-01
Authored To: Exam-Part 2-ST555

Change Logs: 

Updated By: NA
Updated on: NA
Updated to: NA

*/

* Set libraries and options;
x "cd L:/st555/Results/FinalProjectPhase1";
libname Results "."; 

x "cd L:/st555/Data/BookData/BeverageCompanyCaseStudy/";
libname InputDS ".";
filename InputRaw ".";

x "cd S:/Exam";
libname Exam ".";

* Set options;
options nodate nobyline;
ods noproctitle;
ods _all_ close;
ods graphics / width = 6in;
** Set pdf output;
ods pdf file = 'Exam Sadeghi.pdf' dpi = 300 style = sapphire;
ods exclude none;

* Activity 2.1 titles;
title   'Activity 2.1';
title2  'Summary of Units Sold';
title3  'Single Unit Packages';
title4   h = 8pt 'The MEANS Procedure'; 
footnote h = 8pt 'Minimum and maximum Sales are within any county for any week';
* Output 2.1;
PROC means data = Results.AllData(where = ( (unitSize EQ 1) & (productCategory EQ 'Soda: Cola') & (region EQ 'South') )) nonobs sum min max nolabels;
  label stateFips = 'stateFIPS'
        productname = 'productName' 
        size = 'Container Size'
        unitsize = 'Containers per Unit';
  class stateFips productname size unitsize;
  var unitssold; 
run;
title;
footnote;

** Activity 2.3 titles;
title   'Activity 2.3';
title2  'Cross Tabulation of Single Unit Product Sales in Various States';
title3  h = 8pt 'The FREQ Procedure';
* Output 2.3;
PROC freq data = Results.AllData(where = ( (unitSize EQ 1) & (productCategory EQ 'Soda: Cola') & (region EQ 'South') ));
  format unitssold COMMA10.0;
  tables productname*stateFIPS*size;
  weight unitssold;
run;
title;

** Activity 3.1 titles;
title   'Activity 3.1';
title2  'Single-Unit 12 oz Sales';
title3  'Regular, Non-Cola Sodas';
* Output 3.1;
PROC sgplot data = Results.AllData (where = ( (unitSize EQ 1) & (size EQ '12 oz') & (region EQ 'South') & (type EQ 'Non-Diet') & (productCategory EQ 'Soda: Non-Cola') )); 
  hbar statename / response = unitssold
                group = flavor groupdisplay = cluster;             
  keylegend / location = inside position = bottomright down = 3 across = 2 title = ''; 
  xaxis label = 'Total Sold';
  yaxis display = (nolabel);
  attrib unitssold format = COMMA9.0; 
run;
title;

* Activity 3.3 titles;
title   'Activity 3.3';
title2  'Average Weekly Sales, Non-Diet Energy Drinks';
title3  'For 8 oz Cans in Georgia';
* Output 3.3;
PROC sgplot data = Results.AllData (where = ((size EQ '8 oz') & (stateName EQ 'Georgia') & (container EQ 'Can') & (type EQ 'Non-Diet') & (productCategory EQ 'Energy'))); 
  vbar productname / response = unitssold
                group = unitsize groupdisplay = cluster 
                outlineattrs = (color = black)
                dataskin = SHEEN
                stat = mean; 
  xaxis display = (nolabel);
  yaxis label = 'Weekly Average Sales';
  keylegend / location = outside position = bottom down = 1 title = 'UnitSize'; 
run;
title;

* Activity 3.6 titles;
title   'Activity 3.6';
title2  'Weekly Average Sales, Nutritional Water';
title3  'Single-Unit Packages';
* Output 3.6;
PROC sgplot data = Results.Act3_6results;
  hbar productname / response = unitssold_Mean
                barwidth = 0.6;
  hbar productname / response = unitssold_Median
                transparency = 0.4;
  xaxis label = "Georgia, North Carolina, and South Carolina";
  yaxis display = (nolabel);
  keylegend / location = inside position = topright across = 1 noborder title = "Weekly Sales"; 
run;
title;

* Activity 4.1 titles;
title   'Activity 4.1';
title2  'Weekly Sales Summaries';
title3  'Cola Products, 20 oz Bottles, Individual Units';
title4   h = 8pt 'The MEANS Procedure'; 
footnote h = 8pt 'All States'; 
* Output 4.1;
PROC means data = Results.AllData(where = ( (unitSize EQ 1) & (container EQ "Bottle") & (size EQ "20 oz") & (productCategory EQ "Soda: Cola") )) 
  nonobs mean median q1 q3 nolabels maxdec=0;
  label flavor = "Flavor";
  class region type flavor;
  var   unitssold;  
run;
title;
footnote;

* Activity 4.2 titles;
title   'Activity 4.2';
title2  'Weekly Sales Distributions';
title3  'Cola Products, 12 Packs of 20 oz Bottles';
footnote 'All States'; 
* Output 4.2;
PROC sgpanel data = Results.AllData(where = ( (container EQ "Bottle") & (size EQ "20 oz") & (unitSize EQ 12) & (productCategory EQ "Soda: Cola") ));
  panelby region type/ novarname;
  histogram unitssold / binwidth = 250 scale = proportion; 
  rowaxis display = (nolabel) valuesformat = percent10.; 
  format unitssold 8. ;
run;
title;
footnote;

** Activity 4.4 titles;
title   'Activity 4.4';
title2  'Sales Inter-Quartile Ranges';
title3  'Cola: 20 oz Bottles, Individual Units';
footnote 'All States';
* Output 4.4;
PROC sgpanel data = Results.Act4_4results;
  panelby region type/ novarname;  
  highlow x = date high = unitssold_Q3 low = unitssold_Q1; 
  rowaxis label = "Q1-Q3";
  colaxis label = "Date" interval = month valuesformat = MONYY7.; 
run;
title;
footnote;

* Activity #28 (No activity number) titles;
title   'Optional Activity';
title2  'Product Information and Categorization';
* Output #28 (No activity number);
PROC print data = Results.Classification label noobs width = full;
  var productname type productcategory productsubcategory flavor size container;
run;

* Activity 5.5 titles;
title   'Activity 5.5';
title2  'North and South Carolina Sales in August';
title3  '12 oz, Single-Unit, Cola Flavor';
* #28 (No activity number) 5.5;
PROC sgpanel data = Results.Act5_5trans;
  attrib  Date format = mmddyy8.
          North_Carolina label = "North Carolina"
          South_Carolina label = "South Carolina"; 
  panelby type/ novarname columns = 1; 
  hbar Date / response = North_Carolina
                 barwidth = 0.6;
  hbar Date / response = South_Carolina
                transparency = 0.4;
  rowaxis display = (nolabel);
  colaxis label = "Sales" valuesformat = comma7.0 type = linear;
  keylegend / position = bottom down = 1 title = "";
run;
title;

* Activity 6.2 titles;
title   'Activity 6.2';
title2  'Quarterly Sales Summaries for 12oz Single-Unit Products';
title3  'Maryland Only';
* Output 6.2;
PROC report data = Results.AllData(where = ( (stateName EQ "Maryland") & (size EQ "12 oz") & (unitSize EQ 1) ));
  columns type productname date unitssold = salemedian unitssold = saletotal unitssold = salelow unitssold = salehigh;
  define  type / group 'Product Type';
  define  productname / group 'Product Name';
  define  date / group 'Quarter' order = internal format = QTRR.;
  define  salemedian / analysis median 'Median Weekly Sales';
  define  saletotal / analysis sum 'Total Sales';
  define  salelow / analysis min 'Lowest Weekly Sales';
  define  salehigh / analysis max 'Highest Weekly Sales' format = comma7.0; 
    * I could increase the length of comma. format but it seems that Dr. Duggins also used 7 as the length, look at the 
      last reecord "Vanilla Cola" records;
  break   after productname / summarize;
  compute after productname;
    productname = '';
    type = '';
  endcomp;
run;
title;

* Data cleaning for Soda (Activity 7.1); 
DATA Exam.Sodas(drop = i _:);
  infile  InputRaw('Sodas.csv') dsd firstobs = 6 truncover;
  length  productName $20 size $8 code $14;
  input   Number productName $ @;
  do i = 1 to 6; * start cleaning data;
    length  _size $20;
    input   _size $ @;
    * produce inside the parentheses;
    _subsize = scan(_size, 2,"(") ;
    _subsize = tranwrd(_subsize, ')', '');
    * Find the Quantity value;
      do _k = 1 to countc(_subsize,",")+1;
        if countc(_size,"(") EQ 0 then 
          Quantity = 1;
        else if countc(_size,",") EQ 0 then
          Quantity = substr(_size, index(_size,"(")+1,1);
        else 
          Quantity = scan(_subsize, _k);
      * Create size and code;
      size = catx(" ",scan(_size,1), scan(_size,2));
      code = catx("-", "S", Number, size, Quantity);
      if _k ne (countc(_subsize,",")+1) then 
        output;  
      end;
    if(^(missing(_size))) then 
      output; 
  end; * end of cleaning data;

  attrib 
    Number label = "Product Number"
    ProductName label = "Product Name"
    size label = "Individual Container Size" 
    Quantity label = "Retail Unit Size" format = BEST12.
    code label = "Product Code";
run;

* Activity 7.1 titles;
title 'Product Code Mapping for Sodas';
title2 'Created in Activity 7.1';
* Output 7.1;
PROC print data = Exam.Sodas noobs label;
run;

* Activity 7.4 titles;
title   'Activity 7.4';
title2  'Quarterly Sales Summaries for 12oz Single-Unit Products';
title3  'Maryland Only';
* Output 7.4;
proc report data = Results.AllData(where = ( (unitSize EQ 1) & (stateName EQ "Maryland") & (size EQ "12 oz") ))
    style(header) = [color = STB backgroundcolor = grayBE];
  columns type productname date unitssold = salemedian unitssold = saletotal unitssold = salelow unitssold = salehigh;
  define type / group 'Product Type';
  define productname / group 'Product Name';
  define date / group 'Quarter' order = internal format = QTRR.;
  define salemedian / analysis median 'Median Weekly Sales';
  define saletotal / analysis sum 'Total Sales';
  define salelow / analysis min 'Lowest Weekly Sales';
  define salehigh / analysis max 'Highest Weekly Sales' format = comma7.0;
  * I could increase the length of comma. format but it seems that Dr. Duggins also used 7 as the length, look at the 
      last reecord "Vanilla Cola" records;
  break after productname / summarize style(summary) = [color = white backgroundcolor = black];
  compute after productname;
    productname = "";
    type = "";
  endcomp;
  compute date;
     if ((_break_ eq "") or (missing(_break_))) then do; 
        i+1;
        if mod(i,4) EQ 1 then 
            call define(_row_, 'style', 'style=[backgroundcolor=WHITE]');
        else if mod(i,4) EQ 2 then  
            call define(_row_, 'style', 'style=[backgroundcolor=grayF7]');
        else if mod(i,4) EQ 3 then 
            call define(_row_, 'style', 'style=[backgroundcolor=grayE7]');
        else 
            call define(_row_, 'style', 'style=[backgroundcolor=grayAA]');
      end;
  endcomp;
run;
title;

* Activity 7.5 titles;
title   'Activity 7.5';
title2  'Quarterly Per-Capita Sales Summaries';
title3  '12oz Single-Unit Lemonade';
title4  'Maryland Only';
footnote h = 8pt 'Flagged Rows: Sales Less Than 7.5 per 1000 for Diet; Less Than 30 per 1000 for Non-Diet';
* Output 7.5;
PROC report data = Results.AllData(where = ( (flavor EQ "Lemonade") & (unitSize EQ 1) & (size EQ "12 oz") & (stateName EQ "Maryland") )) 
    nowd
    style(header) = [color = STB backgroundcolor = grayAA]
    style(lines)  = [color = white backgroundcolor = black textalign = right];
  columns countyName type date unitssold salesPerThousand popestimate2016;
  define countyName / group 'County';
  define type / group 'Product Type';
  define date / group 'Quarter' format = QTRR. order = internal;
  define unitssold / analysis sum 'Total Sales' format = COMMA12.0;
  define salesPerThousand / analysis sum 'Sales per 1000' format = COMMA12.1;
  define popestimate2016 / analysis median noprint format = COMMA12.0;
  break after countyName / summarize style(summary) = [color = white backgroundcolor = black]; 
  compute countyName;
    countyName = tranwrd(countyName, ' County ', '');
  endcomp;
  compute before date;
    _type = type;
  endcomp;
  compute after countyName;
    countyName = "";
    type = "";
    date = "";
    line "2016 Population: " popestimate2016.median ;
  endcomp;
  compute salesPerThousand;
    if _type eq 'Diet' then do;
      if  salesPerThousand.sum lt 7.5 then do;
        call define(_col_, 'style', 'style=[color=red]');
        call define(_row_,"style","style = {background = grayE7}");
      end;
    end;
    else do;
      if salesPerThousand.sum lt 30 then do;
        call define(_col_, 'style', 'style=[color=red]');
        call define(_row_,"style","style = {background = grayE7}");
      end;
    end;
  endcomp;
run;
title;
footnote;

ods pdf close;
quit;
