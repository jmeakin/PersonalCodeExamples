//Import the Excel data file and save as .dta file
//Manipulate Excel first. Ask whether blank cells should be filled in
set more off
cd "\\dc1fs\dc1ehd\share\NBPTS SEED Evaluation\Evaluation Activities & Dissemination\Certification Pursuit Study\Data Samples and Materials\Stata Tests\Meakin"
use Test_data_file_2015_9_4, clear

tempfile ALL
save `ALL'

replace EmpStateName=subinstr(EmpStateName," ","",.)

levelsof EmpStateName, local(states)
foreach state in `states' {
preserve
keep if EmpStateName=="`state'"
tempfile `state'
save ``state'', replace
restore
}




foreach state in ARIZONA CALIFORNIA KENTUCKY NEWMEXICO NEWYORK WASHINGTON ALL {

use ``state'', clear

foreach category in Gender Ethnicity HighestDegree FILETYPE ENROLLCODE PUPEXPCURR {

//User Status
preserve
table UserStatus, replace

set obs `=_N + 1'
qui su table1
replace table1=r(sum) in L
replace UserStatus="Total" in L

gen Percent=table1/table1[`=_N']
gen Cum=sum(Percent)
replace Cum=. in L
rename table1 Freq

export excel using "Output_`state'.xlsx", firstrow(variables) sheet(`category') sheetmodify cell(A1) 
restore



// Loop Vars

preserve
table `category', replace

set obs `=_N + 1'
qui su table1
replace table1=r(sum) in L
replace `category'="Total" in L

gen Percent=table1/table1[`=_N']
gen Cum=sum(Percent)
replace Cum=. in L
rename table1 Freq

export excel using "Output_`state'.xlsx", firstrow(variables) sheet(`category') sheetmodify cell(F1) 
restore




//User Status and Var
preserve
table `category' UserStatus, replace
replace UserStatus=subinstr(UserStatus," ","",.)
rename table1 t_
reshape wide t_, i(`category') j(UserStatus) string

set obs `=_N + 1'
foreach var of varlist t_* {
qui su `var'
replace `var'=r(sum) in L
}
replace `category'="Total" in L

egen Total=rowtotal(t_*)
rename t_* * 

tempfile table
save `table'
export excel using "Output_`state'.xlsx", firstrow(variables) sheet(`category') sheetmodify cell(A20) 
restore

 
// Column Percentages
preserve

use `table', clear

unab statvars : *
local tabvars : subinstr local statvars "`category'" ""

foreach var in `tabvars' {
replace `var'=`var'/`var'[`=_N']
}
drop Total
export excel using "Output_`state'.xlsx", firstrow(variables) sheet(`category') sheetmodify cell(H20) 

// Row Percentages
use `table', clear

unab statvars : *
local tabvars : subinstr local statvars "`category'" ""

foreach var in `tabvars' {
replace `var'=`var'/Total
}
replace Total=Total/Total
drop if `category'=="Total"
export excel using "Output_`state'.xlsx", firstrow(variables) sheet(`category') sheetmodify cell(N20) 

restore
}

}
