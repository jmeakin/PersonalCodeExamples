*descriptive analysis
set more off
use "\\DC1FA01\DC1WRa\WRA\DOL_1st Responder Diversity Practices\05 Task 3 Develop Research Design\ACS data\ACS_diversityanalysis_state_weight.dta", clear

gen age_category=0 if AGEP<16
replace age_category=1 if AGEP==16 |AGEP==17
replace age_category=2 if AGEP<=24 & AGEP>=18
replace age_category=3 if AGEP<=34 & AGEP>=25
replace age_category=4 if AGEP<=44 & AGEP>=35
replace age_category=5 if AGEP<=54 & AGEP>=45
replace age_category=6 if AGEP<=64 & AGEP>=55
replace age_category=7 if AGEP>=65

label define age_c 0 "younger than 16" 1 "16-17" 2 "18-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65+"
label value age_category age_c

preserve
duplicates drop ST, force
keep ST
decode ST, gen(State)
tempfile states
save `states'
restore

tempfile save 
save `save', replace
clear



*****************ed attainment*****************
*fire
use `save', replace

levelsof ST, local(st)
foreach stat in `st' {
preserve
keep if ST==`stat'
sort SCHL
tab SCHL [aw=PWGTP] if (OCCP10=="3720"|OCCP10=="3740"|OCCP10=="3750"|SOCP10=="3720"|SOCP10=="3740"|SOCP10=="3750"|OCCP12=="3720"|OCCP12=="3740"|OCCP12=="3750"|SOCP12=="3720"|SOCP12=="3740"|SOCP12=="3750"), matcell(y) matrow(x)
clear
svmat y, names (var)
svmat x, names (sch)
gen state=`stat'
tempfile f`stat'
save `f`stat''
restore
}

clear
foreach stat in `st' {
append using `f`stat''
}


reshape wide var1, i(state) j(sch1)
egen tot=rowtotal(var1*)

foreach var of varlist var1* {
gen perc`var'=`var'/tot
}

drop tot

foreach var of varlist var1* perc*{
replace `var'=0 if `var'==.
}

forvalues i=1 2 to 24 {
capture gen var1`i'=""
capture gen percvar1`i'=""
}

rename state ST
merge 1:1 ST using `states'
sort ST
drop _merge ST

order 	State ///
		var11 	percvar11 	var12 	percvar12 	var13 	percvar13	///
		var14	percvar14	var15	percvar15	var16	percvar16	/// 
		var17	percvar17	var18	percvar18	var19	percvar19	/// 
		var110	percvar110	var111	percvar111	var112	percvar112	///
		var113	percvar113	var114	percvar114	var115	percvar115	///
		var116	percvar116	var117	percvar117	var118	percvar118	///
		var119	percvar119	var120	percvar120	var121	percvar121	///
		var122	percvar122	var123	percvar123	var124	percvar124, first
		

cd "\\DC1FA01\DC1WRa\WRA\DOL_1st Responder Diversity Practices\05 Task 3 Develop Research Design\ACS data\temp output"
export excel using "SCHL_Output.xlsx", firstrow(variables) sheet(fire) sheetmod


*EMTs
use `save', replace

levelsof ST, local(st)
foreach stat in `st' {
preserve
keep if ST==`stat'
sort SCHL
tab SCHL [aw=PWGTP] if (OCCP10=="3400"|SOCP10=="3400"|OCCP12=="3400"|SOCP12=="3400"), matcell(y) matrow(x)
clear
svmat y, names (var)
svmat x, names (sch)
gen state=`stat'
tempfile f`stat'
save `f`stat''
restore
}

clear
foreach stat in `st' {
append using `f`stat''
}


reshape wide var1, i(state) j(sch1)
egen tot=rowtotal(var1*)

foreach var of varlist var1* {
gen perc`var'=`var'/tot
}

drop tot

foreach var of varlist var1* perc*{
replace `var'=0 if `var'==.
}

forvalues i=1 2 to 24 {
capture gen var1`i'=""
capture gen percvar1`i'=""
}

rename state ST
merge 1:1 ST using `states'
sort ST
drop _merge ST

order 	State ///
		var11 	percvar11 	var12 	percvar12 	var13 	percvar13	///
		var14	percvar14	var15	percvar15	var16	percvar16	/// 
		var17	percvar17	var18	percvar18	var19	percvar19	/// 
		var110	percvar110	var111	percvar111	var112	percvar112	///
		var113	percvar113	var114	percvar114	var115	percvar115	///
		var116	percvar116	var117	percvar117	var118	percvar118	///
		var119	percvar119	var120	percvar120	var121	percvar121	///
		var122	percvar122	var123	percvar123	var124	percvar124, first
		
		
cd "\\DC1FA01\DC1WRa\WRA\DOL_1st Responder Diversity Practices\05 Task 3 Develop Research Design\ACS data\temp output"
export excel using "SCHL_Output.xlsx", firstrow(variables) sheet(emt) sheetmod


*Police
use `save', replace

levelsof ST, local(st)
foreach stat in `st' {
preserve
keep if ST==`stat'
sort SCHL
tab SCHL [aw=PWGTP] if (OCCP10=="3710"|OCCP10=="3850"|OCCP10=="3860"|SOCP10=="3710"|SOCP10=="3850"|SOCP10=="3860"|OCCP12=="3710"|OCCP12=="3850"|OCCP12=="3860"|SOCP12=="3710"|SOCP12=="3850"|SOCP12=="3860"), matcell(y) matrow(x)
clear
svmat y, names (var)
svmat x, names (sch)
gen state=`stat'
tempfile f`stat'
save `f`stat''
restore
}

clear
foreach stat in `st' {
append using `f`stat''
}


reshape wide var1, i(state) j(sch1)
egen tot=rowtotal(var1*)

foreach var of varlist var1* {
gen perc`var'=`var'/tot
}

drop tot

foreach var of varlist var1* perc*{
replace `var'=0 if `var'==.
}

forvalues i=1 2 to 24 {
capture gen var1`i'=""
capture gen percvar1`i'=""
}

rename state ST
merge 1:1 ST using `states'
sort ST
drop _merge ST

order 	State ///
		var11 	percvar11 	var12 	percvar12 	var13 	percvar13	///
		var14	percvar14	var15	percvar15	var16	percvar16	/// 
		var17	percvar17	var18	percvar18	var19	percvar19	/// 
		var110	percvar110	var111	percvar111	var112	percvar112	///
		var113	percvar113	var114	percvar114	var115	percvar115	///
		var116	percvar116	var117	percvar117	var118	percvar118	///
		var119	percvar119	var120	percvar120	var121	percvar121	///
		var122	percvar122	var123	percvar123	var124	percvar124, first
		
		
cd "\\DC1FA01\DC1WRa\WRA\DOL_1st Responder Diversity Practices\05 Task 3 Develop Research Design\ACS data\temp output"
export excel using "SCHL_Output.xlsx", firstrow(variables) sheet(police) sheetmod


