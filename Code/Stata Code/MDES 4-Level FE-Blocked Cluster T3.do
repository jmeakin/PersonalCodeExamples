set more off
* Model 4.4:  MDES Calculator for 4-Level Fixed Effects Blocked Cluster Random Assignment Designs (BCRA4_3f)—Treatment at Level 3

* Below, you specify the scalars beside each of the inputs (mirrors input to PowerUp tool
local alpha =	.05	 		// Alpha Level (a): Probability of a Type I error
local tails =	2			// Two-tailed or One-tailed Test?
local power =	.8			// Power (1-ß) Statistical power (1-probability of a Type II error)
local rho3 	=	0.0759 		// Rho3 (ICC3) Proportion of variance among Level 3 units (V3/(V1 + V2 + V3)) 
local rho2 	=	0.1373		// Rho2 (ICC2) Proportion of variance among Level 2 units (V2/(V1 + V2 + V3))
local p		=	.5			// Proportion of level 3 units randomized to treatment:  KT / (KT + KC)
local r21	=	0.207		// Proportion of variance in the Level 1 outcome explained by Level 1 covariates
local r22	=	0.488		// Proportion of variance in the Level 2 mean outcome explained by Level 2 covariates
local r23	=	0.683		// Proportion of variance in the Level 3 mean outcome explained by Block and Level 3 covariates
local g		=	10			// Number of Level 3 covariates
*local n		=	4		// n (Average Sample Size [Students]): Mean number of Level 1 units per Level 2 unit (harmonic mean recommended)
*local J		=	12		// J (Average Sample Size  for Level 2 [Classes #]): Mean number of Level 2 units per Level 3 unit (harmonic mean recommended)	
*local K		=	12		// K (Sample Size for Level 3 [School #]): Mean number of Level 3 units per Level 4 unit (harmonic mean recommended)
local L		=	4			// L (Sample Size for Level 4 [District #]): Number of Level 4 units




/* 
The code below creates separate tables (one each for varying numbers of classes per school) 
with students per class as the columns, schools per district as the rows, and MDES in the cells
*/


/* 
The outer most loop is for individual tables (in the current specification, it 
creates tables for varying numbers of classes per school).
*/

foreach J in 8 9 10 11 12 { // You specify the numbers here, one table will be created for each number and the numbers indicate the number of classes per school
clear all

matrix Rooms`J'= J(20,20,.)

foreach K in 12 13 14 15 16 { // You specify the numbers here, these will be the rows (nunber of schools per district)
foreach n in 4 5 6 7 8 { // You specify the numbers here, these will be the rows (nunber of sstudnets per class)

* These calculations mirror those in the PowerUp tool (Note that I have not given the option for a study with power less  than .5 and I am also imposing a 2 tailed test
* Also Note: These formulas are specific to Model 4.4
*************** Power Calcuations ***************	***************
local T1_2tail = 	abs(invt(`L'*(`K'-2)-`g',`alpha'/2))  
local T2 	   =	abs(invt(`L'*(`K'-2)-`g', (1-`power'))) 
local multiplier = `T1_2tail'+`T2'
local mdes = `multiplier'*sqrt(`rho3'*(1-`r23')/(`p'*(1-`p')*`L'*`K')+`rho2'*(1-`r22')/(`p'*(1-`p')*`J'*`K'*`L')+(1-`rho2'-`rho3')*(1-`r21')/(`p'*(1-`p')*`J'*`n'*`K'*`L'))
***************	***************	***************	***************

matrix Rooms`J'[`K', `n']=`mdes'
}
}

svmat Rooms`J', names(_)
*dropmiss*
gen schools=_n
egen temp=rowtotal(_*)
drop if temp==0
drop temp
gen classes=`J'
order classes schools, first
set obs `=_N+1'
tempfile table`J'
save `table`J'', replace
clear
}


clear
foreach J in 8 9 10 11 12 {
append using `table`J''
}

browse


