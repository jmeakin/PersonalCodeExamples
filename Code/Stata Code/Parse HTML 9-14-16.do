

set more off
local wda  `" "Berkshire County" "Boston" "Bristol County" "Brockton" "Cape & Islands" "Central MA" "Franklin_Hampshire" "Greater Lowell" "Greater New Bedford" "Hampden County" "Lower Merrimack Valley" "Massachusetts" "Metro North" "Metro South_West" "North Central" "North Shore" "South Shore" "'
local wda2 : subinstr local wda " " "", all
local wda3 : subinstr local wda2 "&" "", all
*local test `"a"b"c"'

foreach w in `wda' {
cd "\\Dc1fs\dc1ehd\share\MA NSFY\Labor Market Information\Website Data\Industry Projections for `w' WDA\lmi2.detma.org\Lmi" 


****************************************
local f : dir . files "IndustryOccupationalProjection*.xls"

foreach html in `f' {

copy `html' temp.txt, replace

import delimited temp.txt, clear
egen newvar=concat(v*)
replace newvar=subinstr(newvar,"&nbsp;&nbsp;</td><td>","#",.)
replace newvar=subinstr(newvar,`"<tr class="criteria_table_td"><td HEADERS="header0" align=left>"',"START", .)
replace newvar=subinstr(newvar,`"&nbsp;&nbsp;</td></tr>"',"", .)
replace newvar=subinstr(newvar,`"</table>"',"", .)
replace newvar=subinstr(newvar,`"&nbsp;&nbsp"',"", .)


split newvar,p("START")

local info1 = v1 in 4
local info2 = v1 in 5

keep newvar*
drop newvar newvar1
keep in 8

set obs `=`c(k)'+1'
gen Data=""
forvalues i= 2 3 to `c(k)' {
local data`i' = newvar`i' in 1
replace Data="`data`i''" in `i'
}
gen Info1="`info1'"
gen Info2="`info2'"

keep Data Info1 Info2


capture append using `master'
tempfile master
save `master'

}

use `master', clear
****************************************

local s `"`w'"'
local sa : subinstr local s " " "", all
local save : subinstr local sa "&" "", all

tempfile `save'
save ``save''
}

clear
foreach temp in `wda3' {
append using ``temp''
}

duplicates drop




* Clean Data
gen Industry=subinstr(Info1,"Industry/Occupational Projections for ","",.)
gen Region=subinstr(Info2,"in the ","",.)

split Data, p("#")
replace Data1=subinstr(Data1,";","",.)
rename Data1 Occupation
drop if Occupation==""
destring Data*, replace
rename Data2 Number2014
rename Data3 PctDistn2014
rename Data4 Projected2024
rename Data5 ProjDistn2024
rename Data6 TenYrChange
rename Data7 TenYrChangePct
drop Data Info1 Info2

cd "\\Dc1fs\dc1ehd\share\MA NSFY\Labor Market Information"
export excel "Industry Occupational Projections.xlsx", firstrow(variables) replace



