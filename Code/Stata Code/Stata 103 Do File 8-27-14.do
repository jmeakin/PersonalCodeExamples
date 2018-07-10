clear
cd "\\il2filesvr\groups\Stata Courses\Stata 103\Log Files"
set more off 
capture log close 
set logtype text 
log using "Stata103_`c(current_date)'_`c(hostname)'", replace 


************************************
************************************
* Macro Basics (Slides 9 to 13)
************************************
************************************

************************************
* Basic Macro Syntax (Slide 12)
************************************

* Create a local macro called "daysofweek" that is a list of the days of the week (exclude weekends)
local daysofweek Monday Tuesday Wednesday Thursday Friday

* display the local macro "daysofweek" that you just created
display "`daysofweek'"

* example of a macro with compound double quotes
local quoteexample `" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "'
macro list _quoteexample

* Create a global macro called daysofweek that is a list of the days of the week
global daysofweek Monday Tuesday Wednesday Thursday Friday Saturday Sunday

* display the global macro "daysofweek" that you just created
display "$daysofweek"

* you can call local and global macros the same thing
display "`daysofweek'"
display "$daysofweek"

* Another local macro example
local x 123
local y 456
local z `x'+`y'
macro list _z
display `z'

* See what macros you have created so far (notice that the local macros are just global macros with and underscore)
macro list _all

************************************
* Macro Assignment (Slide 13)
************************************

* assign local macros called  "examplemacro1 & 2" that are not evaluated as an expression
local examplemacro1 "2+2"
macro list _examplemacro1
local examplemacro2 2+2
macro list _examplemacro2

* assign a local macro where the macro is evaluated as an expression
local examplemacro4 = 2+2
macro list _examplemacro4

* another example (overwrites existing local macro called z)
macro list _z
local z = `x'+`y'
macro list _z

************************************
************************************
* Macro Extended Functions (Slides 14 to 19)
************************************
************************************

************************************
* Macro Extended Functions For manipulating lists (Slide 16)
************************************

* "uniq" returns your macro with duplicate elements removed.
local listofnames John James Bill Mary Susan John Dave
display "`listofnames'"

local listofuniquenames : list uniq listofnames
display "`listofuniquenames'"

* dups returns the duplicate elements of your macro
local listofduplicatenames : list dups listofnames
display "`listofduplicatenames'"



* Thinking About Macros as Sets
local A 1 2 3 4 5 6 7 
local B 5 6 7 8 9 10 11 12
display "`A'"
display "`B'"

* A | B returns the union of A and B, the result being equal to A with elements of B not found in
local AorB: list A | B
display "`AorB'"

* A & B returns the intersection of A and B.
local AandB: list A & B
display "`AandB'"

* A - B returns a list containing elements of A with the elements of B removed, with the resulting elements in the same order as A.
local AandnotB: list A - B
display "`AandnotB'"


************************************
* Macro Extended Functions For for Parsing (Slide 17)
************************************

* create a local macro called parsingexamplle
local parsingexample a b c d e f g aa bb cc dd ee ff gg aaa bbb ccc ddd eee fff ggg
macro list _parsingexample

* create a local macro called "countofquestion" that is the number of words in the macro "question" 
local countofparsingexample: word count `parsingexample'
macro list _countofparsingexample

* create a local macro called "lengthofquestion" that is the number of words in the macro "question" 
local lengthofparsingexample: length local parsingexample
macro list _lengthofparsingexample

* create a local macro where the first a in the macro question2 is capitalized
local capitalizefirstA : subinstr local parsingexample "a" "A" 
macro list _capitalizefirstA

* create a local macro where all A's in the macro question2 are capitalized
local capitalizeallA : subinstr local parsingexample "a" "A", all
macro list _capitalizeallA

************************************
* Macro Extended Functions For filenames and file paths (Slide 18)
************************************

* list all of the folders on the share
set more off
cd "H:\share"
local directoriesonshare: dir . dirs "*", respectcase
macro list _directoriesonshare

* list all of the folders in the stata 103 folder
local 103dirs: dir "\\il2filesvr\groups\Stata Courses\Stata 103" dirs "*", respectcase
macro list _103dirs

* list all of the folders in the stata 103 folder that contain the word "Files"
local 103filefolders: dir "H:\share\Stata Courses\Stata 103" dirs "*Files", respectcase
macro list _103filefolders

* list all of the excel files in the "Common Core" data folder
cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files\Common Core"
local ccdfiles: dir . files "*xls", respectcase
macro list _ccdfiles

************************************
* Macro Extended Functions For for extracting data attributes (Slide 19)
************************************

* upload the citytemp dataset into memory
sysuse citytemp, clear

* create a local macro that is the value label of division
local divisionvallabel: value label division
macro list _divisionvallabel

* create a local macro that is the format of heatdd
local heatddformat: format heatdd
macro list _heatddformat

* format tempjan the same as heatdd using the local macro you just created
format tempjan `heatddformat'

************************************
************************************
* Other Useful Ways To Create Macros (Slides 20 to 24)
************************************
************************************

************************************
* Accessing Stored Returns (Slide 21)
************************************
set more off 

* see the list of all local macros stata has in memmory 
creturn list

sysuse auto
* access some of these macros
display "Today is `c(current_date)'. The dataset in memory has `c(N)' observations. This computer is called `c(hostname)'" 

* example of r-class commands
* summarize the price variable
sum price 
* view returns stored after this comand
return list
* use returns stored after this comand
gen pricestandardized=(price-r(mean))/r(sd)

* summarize the price variable (more detail)
sum price, d
return list

tab foreign 
return list

* example of e-class commands
* regress price on mpg, headroom, and weight (cluster standard errors by foreign)
reg price mpg headroom weight, vce(cluster foreign)
* view returns stored after this comand
return list
* view ereturns stored after this comand
ereturn list

* look at variance covariance matrix
matrix list e(V)


************************************
* Using The levelsof Command (Slide 22)
************************************

sysuse census, clear

* create a local macro called "states" that lists all the values of the variable state
levelsof state, local(states)
macro list _states

* create a local macro called "states" that lists all the values of the variable state (use the clean option)
levelsof state, local(statesclean) clean
macro list _statesclean

************************************
* Using The ds Command (Slide 23)
************************************

* list all of the variables in your dataset
ds *
return list

* list all of the numeric variables in your dataset
ds, has(type numeric)
return list

* list all of the string variables in your dataset
ds, has(type string)
return list

************************************
* tempfile and tempvar (Slide 24)
************************************

* use the system file "lifeexp"
sysuse lifeexp
* preserve the data
preserve
* collapse the data to means of lexp, by region
collapse (mean) lexp, by(region)
* rename lexp meanlexp
rename lexp meanlexp
* save the collapsed file to temporary memory
tempfile summary
save `summary'
* restore the original lifeexp dataset
restore
* merge in the collapsed dataset on the variable region
merge m:1 region using `summary'
clear


************************************
************************************
* forvalues (Slides 28 to 30)
************************************
************************************

************************************
* Basic Syntax (forvalues) (Slide 29)
************************************

* simple forvalues example
* for the integers from 1 to 10 display each one by one (multiplied by 2)
clear
set obs 10

forvalues i=1 2 to 10 {
display `i'*2
gen Variable`i'=`i'
}

************************************
* Number Lists (Slide 30)
************************************


* examples of ways to list the numbers 1 to 10 in increments of 1
* for the values 1 to 10 display each one by one (with 5 added to each)
clear
set obs 10
forvalues i= 1 2:10 {
display `i'+5
gen Variable`i'=`i'+5
}

* for the the integers from1 to 10 display each one by one (with 5 added to each)
clear
set obs 10
forvalues j= 1 2 to 10 {
display `j'+5
gen Variable`j'=`j'+5
}

* for the integers from 1 to 10 display each one by one (with 5 added to each)
clear
set obs 10
forvalues k=1(1)10 {
display `k'+5
gen Variable`k'=`k'+5
}

* transform each of the variables in your data set
forvalues number= 1 2 to 10 {
replace Variable`number'=Variable`number'*10
}



* you can do a double (or tripple, or more) loop
clear 
set obs 10
forvalues i=1 2 to 5 {
forvalues j=6 7 to 10 {
forvalues k=11 12 to 15 {
gen variable`i'_`j'_`k'=`i'+`j'+`k'
}
}
}


************************************
************************************
* foreach (Slides 31 to 34)
************************************
************************************

************************************
* Basic Syntax (foreach) (Slide 32)
************************************

* simple foreach example
foreach letter in a b c d e f g {
display "`letter'"
gen Letter_`letter'=""
}

************************************
* List Types (Slide 33)
************************************

* create a local macro called "foreachexample" that is a list of the numbers 1-6 (spelled out)
local foreachexample One Two Three Four Five Six

* display each of the values of the local macro "foreachexample"
foreach number of local foreachexample {
display "`number'"
}

* reference a numberlist in a foreach command
foreach number of numlist 1(1)10 {
display `number'+5
gen Number_`number'=""
}

************************************
* Variable Lists (Slide 34)
************************************

sysuse uslifeexp, clear

* summarize each variable from le to le_bfemale (as the variables are currently ordered)
foreach var of varlist le-le_bfemale {
sum `var'
}

* summarize each variable from starting with le and ending with anythign
foreach var of varlist le*{
sum `var'
}

* summarize each variable from starting with le, ending with male, and with any two characters in between
foreach var of varlist le??male {
sum `var'
}


************************************
************************************
* while (Slides 35 to 36)
************************************
************************************

************************************
* Basic Syntax (while) (Slide 36)
************************************

* generate 40 variables that are each random numbers between 0 and 1
clear
browse
set obs 10
local i = 1
while `i' < 40 {
gen Uniform`i' = runiform()
local i = `i' + 1
}

* generate 40 variables that are each random numbers between 0 and 1 (using forvalues)
clear
set obs 10
forvalues i= 1 2 to 40 {
gen Uniform`i' = runiform()
}


************************************
************************************
* Loops and Macros Practical Examples 
************************************
************************************


************************************************************************
* Upload all of the data in the Common Core Folder
************************************************************************
clear
set more off
* change stata's working directory
cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files\Common Core"
* create a local macro called "ccdfiles" that is a list of all the excel files in the above directory
local ccdfiles : dir . files "*.xls"

* foreach excel file listed in the macro just created: 
foreach file of local ccdfiles {
* import the file
import excel using "`file'", firstrow
* apped the previously imported data (capture applies to the first round)
capture append using `master'
* resave the file as master for append to a new sheet
tempfile master
save `master', replace
clear
}
* upload the final data (all sheets combined)
use `master', clear
drop locale_10 puptch_10 fte_10 pk_10- g12_10 year_10


* replace all missing numeric values with zero
* replace all values over 1000 with missing
ds, has(type numeric)
return list
foreach var of varlist `r(varlist)' {
replace `var'=0 if `var'==.
replace `var'=. if `var'>1000
}

* generate a valid data flag (all numeric variables must be non-missing)
ds, has(type numeric)
local numnumeric:  word count `r(varlist)'
macro list _numnumeric
egen temp=rownonmiss(`r(varlist)')
gen ValidData=1 if temp==`numnumeric'
************************************************************************



************************************************************************
* Create tables for each of the states and export to an excel file
************************************************************************
* create numeric values for the string state variable (will be used in forvalues)
encode lstate_10, gen(stnum)

* foreach integer from 1 to 51 (all the values of the numeric state variable just created)
forvalues k=1 2 to 51 {
* preserve the master data set
preserve
* keep only one state
keep if stnum==`k'

* create a local macro that is the state name
levelsof lstate_10, local(state) clean

* clean the type_10 variable
forvalues i=1 2 to 5 {
replace type_10=subinstr(type_10, "`i'-", "",.)
replace type_10=subinstr(type_10, "/", "",.)
}

* create a table that replaces the data in memory
table titleistat_10 type_10, replace
* reshape the table
reshape wide table1, i(titleistat_10) j(type_10) string
rename table1* *

* add a title to the table (that is the state's name) using the "state" macro created above
set obs `=_N+1'
sort titleistat_10
replace titleistat_10="`state'" if titleistat_10==""


cd "\\il2filesvr\groups\Stata Courses\Stata 103\Output"
* export to an excel sheet (specify the cell range as 12 times the state number so that tables dont overlap)
export excel using "Final Tables", firstrow(variables) cell(A`=12 * `k'') sheet(Tables) sheetmod
restore
}
************************************************************************


* One case example of above
******************************
preserve
keep if stnum==1
levelsof lstate_10, local(state) clean

tab type_10
forvalues i=1 2 to 5 {
replace type_10=subinstr(type_10, "`i'-", "",.)
replace type_10=subinstr(type_10, "/", "",.)
}

table titleistat_10 type_10, replace
reshape wide table1, i(titleistat_10) j(type_10) string
rename table1* *
set obs `=_N+1'
sort titleistat_10
replace titleistat_10="`state'" if titleistat_10==""
restore
******************************


************************************************************************
* Upload all of the data in the State Data excel sheets
************************************************************************
clear
cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files"
import excel using "State Data", describe

forvalues i = 1 2 to `r(N_worksheet)' {
cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files"
import excel using "State Data" , sheet ("`r(worksheet_`i')'") allstring firstrow

gen sheetid="`r(worksheet_`i')'"

cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files\Temporary Files"
save "`r(worksheet_`i')'", replace
clear
}

cd "\\il2filesvr\groups\Stata Courses\Stata 103\Data Files\Temporary Files"
local statefile : dir . files "*"
clear
foreach file of local statefile {
append using "`file'"
}
************************************************************************



************************************************************************
* Create An Example Data Set
************************************************************************
clear

forvalues k=1 2 to 20 {

set obs 1
gen uni = 1+int((100-1+1)*runiform())
levelsof uni, local(num)
drop uni
set obs `num'

forvalues i=1 2 to 15 {
gen Question`i'=rbinomial(3, .75)
}


gen School="School `k'"
gen N=[_n]
tostring N, replace
gen SurveyTaker="`k'Taker"+N
drop N

tempfile School`k'
save `School`k'', replace
clear
}

forvalues j=1 2 to 20 {
append using `School`j''
}

************************************************************************

************************************************************************
* Create Tables
************************************************************************
forvalues i= 1 2 to 15 {
preserve
table Question`i' School, replace
reshape wide table1, i(School) j(Question`i')

set obs `=_N + 1'
ds, has(type numeric)

qui foreach v in `r(varlist)' {
su `v'
replace `v' = r(sum) in L
}

replace School="Total" if School==""

egen N=rowtotal(table1*)
gen PercentNever=table10/N
gen PercentSometimes=table11/N
gen PercentOften=table12/N
gen PercentAlways=table13/N

foreach var of varlist Perc* {
replace `var'=0 if `var'==.
}

keep Percent* N School

cd "\\il2filesvr\groups\Stata Courses\Stata 103\Output"
export excel using "Survey Tables", firstrow(variables) sheet(Question`i') sheetreplace
restore
}


************************************************************************


* One case example of above
******************************
preserve
table Question1 School, replace
reshape wide table1, i(School) j(Question1)

set obs `=_N + 1'
ds, has(type numeric)

qui foreach v in `r(varlist)' {
su `v'
replace `v' = r(sum) in L
}

replace School="Total" if School==""

egen N=rowtotal(table1*)
gen PercentNever=table10/N
gen PercentSometimes=table11/N
gen PercentOften=table12/N
gen PercentAlways=table13/N

foreach var of varlist Perc* {
replace `var'=0 if `var'==.
}

keep Percent* N School
******************************

capture log close 



