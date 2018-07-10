
clear
set more off
capture log close 


*Merge data sources

cd "L:\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Video Analysis\Compiled District Units\Final\Intel Math"

*LC
import excel using "Video Coding_Las Cruces_Units 2357", firstrow case(lower) clear
tempfile chunks
save `chunks', replace

import excel using "Video Coding_Las Cruces_Units 1468", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

*Portland
import excel using "Video Coding_Portland_Units 2357", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

import excel using "Video Coding_Portland_Units 1468", firstrow case(lower)  clear
append using `chunks', force
save `chunks', replace

*Henrico
import excel using "Video Coding_Henrico_Units 2357", firstrow case(lower)  clear
append using `chunks', force
save `chunks', replace

import excel using "Video Coding_Henrico_Units 1468", firstrow case(lower)  clear
append using `chunks', force
save `chunks', replace

*WC
import excel using "Video Coding_Washington County_Units 2357", firstrow case(lower)  clear
append using `chunks', force
save `chunks', replace

import excel using "Video Coding_Washington County_Units 1468", firstrow case(lower)  clear
append using `chunks', force
save `chunks', replace

*SLC
import excel using "Video Coding_Salt Lake City_Units 2357", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

import excel using "Video Coding_Salt Lake City_Units 1468", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

*Henry
import excel using "Video Coding_Henry_Units 2357", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

import excel using "Video Coding_Henry_Units 1468", firstrow case(lower) clear
append using `chunks', force
save `chunks', replace

sort district day
drop in 1/22 // empty information
drop r s t u v w x y // variables with missing information

cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
save videos, replace


**** summarize data
cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
use videos, clear
set more off

/*NOTE: there are seven recordings that are missing the length and activity information. Some of them are also missing its session and unit information. I'm going to drop them. 
*/
drop if activity == "" | session == "" | unit == ""

*identify pedagogy sessions
generate pedagogy=0
replace pedagogy=1 if session=="5_5 Pedagogy: Student Understanding of Fractions" | session=="2_5 Pedagogy: Student Understanding of Subtraction" | session=="7_4 Pedagogy: Student Understanding of Linear Equations" | ///
					  session=="3_5 Pedagogy: Student Understanding of Multiplication" | session == "1.5 Pedagogy: Student Understanding of Addition" | session == "6.6 Pedagogy: Student Understanding of Place Value" | ///
					  session == "4.3 Pedagogy: Student Understanding of Division"
					  
replace pedagogy=2 if unit=="Homework"
replace pedagogy=3 if unit=="Review"
replace pedagogy= 4 if unit == "Orientation"
replace pedagogy= 5 if activity == "Other" | activity == "Other-Inventory"

label define peda 0 "Non-Pedagogy Sessions" 1 "Pedagogy Sessions" 2 "Homework" 3 "Review" 4 "Orientation" 5 "Other", replace
label values pedagogy peda

*calculate segment lengths

generate length=segmentend-segmentstart
generate lengthmin=length/60000
generate lengthhrs=lengthmin/60
summ length lengthmin

*create variable for length of just active instruction
generate lengthforcoders=lengthmin if activity=="Presentation of Content" | activity=="Table Work Share"



***Exhibit 1A: Length of units, hours***

gen unit_mod = unit
replace unit_mod = "Other" if activity == "Other" | activity == "Other-Inventory"
encode unit_mod, gen(unitnum)
recode unitnum (5 = 1) (6 = 2) (7 = 3) (8 = 4) (9 = 5) (10 = 6) (11 = 7) (12 = 8) (1 = 9) (4 = 10) (2 = 11) (3 = 12) // note: value name labels are now wrong. Corrected below.
label define unit 1 "Unit 1" 2 "Unit 2" 3 "Unit 3" 4 "Unit 4" 5 "Unit 5" 6 "Unit 6" 7 "Unit 7" 8 "Unit 8" 9 "Homework" 10 "Review" 11 "Orientation" 12 "Other"
label values unitnum unit

bysort unit_mod: egen sum_all_lengthhrs = total(lengthhrs)
bysort district unit_mod: egen sum_lengthhrs = total(lengthhrs)
egen tag_unit = tag(unit_mod)
egen tag_d_unit = tag(district unit_mod)
bysort unit_mod: egen avg_all_lengthhrs = mean(sum_lengthhrs) if tag_d_unit == 1


matrix define A = J(13,8,.)

matrix colnames A = "All Districts - hours" "All Districts - Average" "Henrico" "Henry" "Las Cruces" "Portland" "Salt Lake City" "Washington County" 	
matrix rownames A = "Unit 1" "Unit 2" "Unit 3" "Unit 4" "Unit 5" "Unit 6" "Unit 7" "Unit 8" "Homework" "Review" "Orientation" "Other" "Total"


encode district, gen(dnum)
set more off

forvalues k = 1 2 to 6 {

preserve
keep if tag_d_unit == 1 & dnum == `k'

	forvalues x = 1/12 {
	
	sum sum_lengthhrs if unitnum == `x'
	
	if r(N) > 0 {
	scalar leng = r(mean)
	matrix A[`x',`k' + 2] = leng
	}
	
	if r(N) == 0 {
	scalar leng = 0
	matrix A[`x',`k' + 2] = leng
	}
	
	
	}
	
	bysort district: egen sum_total = total(sum_lengthhrs)
	sum sum_total
	scalar leng = r(mean)
	matrix A[13,`k' + 2] = leng

restore
}

forvalues x = 1/12 {
	
	sum sum_all_lengthhrs if unitnum == `x'
	scalar leng = r(mean)
	matrix A[`x', 1] = leng
	
	}

preserve
keep if tag_unit == 1
egen sum_all_total = total(sum_all_lengthhrs)
sum sum_all_total
return list
scalar leng = r(mean)
matrix A[13,1] = leng
restore

*Average column

forvalues x = 1/13 {
scalar avg = (A[`x',3] + A[`x',4] + A[`x',5] + A[`x',6] + A[`x',7] + A[`x',8])/6
matrix A[`x',2] = avg
}

cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
xml_tab A, save(exhibit1a.xls) replace


***Exhibit 1B: Length of units, proportions***

matrix define A = J(13,8,.)

matrix colnames A = "All Districts - prop" "All Districts - Average prop" "Henrico" "Henry" "Las Cruces" "Portland" "Salt Lake City" "Washington County" 	
matrix rownames A = "Unit 1" "Unit 2" "Unit 3" "Unit 4" "Unit 5" "Unit 6" "Unit 7" "Unit 8" "Homework" "Review" "Orientation" "Other" "Total"


forvalues k = 1 2 to 6 {

preserve
keep if tag_d_unit == 1 & dnum == `k'

bysort district: egen sum_total = total(sum_lengthhrs)
sum sum_total
scalar total_leng = r(mean)
matrix A[13,`k' + 2] = 100

	forvalues x = 1/12 {
	
	sum sum_lengthhrs if unitnum == `x'
	
	if r(N) > 0 {
	scalar leng = r(mean)
	matrix A[`x',`k' + 2] = (leng/total_leng)*100
	}
	
	if r(N) == 0 {
	scalar leng = 0
	matrix A[`x',`k' + 2] = leng
	}
	
	
	}
	
restore
}

*Average column

	forvalues x = 1/13 {
	scalar avg = (A[`x',3] + A[`x',4] + A[`x',5] + A[`x',6] + A[`x',7] + A[`x',8])/6
	matrix A[`x',2] = avg
	}

*All district proportion column

preserve
keep if tag_unit == 1
egen sum_all_total = total(sum_all_lengthhrs)
sum sum_all_total
scalar total_leng = r(mean)
restore

	forvalues x = 1/12 {
	
	sum sum_all_lengthhrs if unitnum == `x'
	scalar leng = r(mean)
	matrix A[`x', 1] = (leng/total_leng)*100
	}
	
matrix A[13,1] = 100

cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
xml_tab A, save(exhibit1b.xls) replace


***Exhibit 2a: Length of Sessions Types, Hours***

capture drop sum_all_lengthhrs sum_lengthhrs

bysort pedagogy: egen sum_all_lengthhrs = total(lengthhrs)
bysort district pedagogy: egen sum_lengthhrs = total(lengthhrs)
egen tag_d_peda = tag(district pedagogy)
egen tag_peda = tag(pedagogy)


matrix define A = J(7,8,.)

matrix colnames A = "All Districts-Total" "All Districts-Average"  "Henrico"  "Henry"  "Las Cruces" "Portland" "Salt Lake City" "Washington County"	
matrix rownames A = "Non-Pedagogy Session" "Pedagogy Session" "Homework" "Review" "Orientation" "Other" "Total"

capture drop dnum
encode district, gen(dnum)


forvalues k = 1 2 to 6 {

preserve
keep if tag_d_peda == 1 & dnum == `k'

egen sum_total = total(sum_lengthhrs)
sum sum_total
scalar total_leng = r(mean)
matrix A[7, 3 + (`k'-1)] = total_leng

	forvalues x = 0/5 {
	
	sum sum_lengthhrs if pedagogy == `x'
	
	if r(N) > 0 {
	scalar leng = r(mean)
	scalar prop = (leng/total_leng)*100
	matrix A[`x'+1, 3 + (`k'-1)] = leng
	}
	
	if r(N) == 0 {
	scalar leng = 0
	scalar prop = 0
	matrix A[`x'+1, 3 + (`k'-1)] = leng
	}

	
	}
	
restore

}

preserve
keep if tag_peda == 1

egen sum_all_total = total(sum_all_lengthhrs)
sum sum_all_total
scalar total_leng = r(mean)
matrix A[7, 1] = total_leng

	forvalues x = 0/5 {
	sum sum_all_lengthhrs if pedagogy == `x'
	scalar leng = r(mean)
	matrix A[`x'+1,1] = leng
	}
	
restore

*Average column

	forvalues x = 1/7 {
	scalar avg = (A[`x',3] + A[`x',4] + A[`x',5] + A[`x',6] + A[`x',7] + A[`x',8])/6
	matrix A[`x',2] = avg
	}


cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
xml_tab A, save(exhibit2a.xls) replace


***Exhibit 2b: Length of Sessions Types, Proportions***


matrix define A = J(7,8,.)

matrix colnames A = "All Districts-Total" "All Districts-Average" "Henrico" "Henry" "Las Cruces" "Portland" "Salt Lake City" "Washington County" 	
matrix rownames A = "Non-Pedagogy Session" "Pedagogy Session" "Homework" "Review" "Orientation" "Other" "Total"


forvalues k = 1 2 to 6 {

preserve
keep if tag_d_peda == 1 & dnum == `k'

egen sum_total = total(sum_lengthhrs)
sum sum_total
scalar total_leng = r(mean)

	forvalues x = 0/5 {
	
	sum sum_lengthhrs if pedagogy == `x'
	
	if r(N) > 0 {
	scalar leng = r(mean)
	scalar prop = (leng/total_leng)*100
	matrix A[`x'+1, 3 + (`k'-1)] = prop
	}
	
	if r(N) == 0 {
	scalar leng = 0
	scalar prop = 0
	matrix A[`x'+1, 3 + (`k'-1)] = prop
	}

	
	}
	
matrix A[7,3 + (`k'-1)] = 100
	
restore

}

preserve
keep if tag_peda == 1

egen sum_all_total = total(sum_all_lengthhrs)
sum sum_all_total
scalar total_leng = r(mean)
matrix A[7, 1] = 100

	forvalues x = 0/5 {
	sum sum_all_lengthhrs if pedagogy == `x'
	scalar leng = r(mean)
	scalar prop = (leng/total_leng)*100
	matrix A[`x'+1,1] = prop
	}
	
restore

*Average column

	forvalues x = 1/7 {
	scalar avg = (A[`x',3] + A[`x',4] + A[`x',5] + A[`x',6] + A[`x',7] + A[`x',8])/6
	matrix A[`x',2] = avg
	}

cd "\\Dc1fs\dc1ehd\share\Math PD Study 2012-2016\Task 7 - Implementation Support\Implementation Analysis\PD Video Analysis\Chunk Summaries"
xml_tab A, save(exhibit2b.xls) replace


***Exhibit 3: Length of Sessions, Minutes***

matrix define A = J(7,6,.)
matrix rownames A =  "Non-Pedagogy Session" "Pedagogy Session" "Homework" "Review" "Orientation" "Other" "Overall"
matrix colnames A = "N of Sessions" "Sum of Session Lenghts" "Mean Length of Sessions" "SD" "Minimum Session Length" "Maximum Session Length"

*redefine session
gen session_mod = session
replace session_mod = "Other" if activity == "Other" | activity == "Other-Inventory"


/* *I was getting the order of the rownames wrong. 
label define order 1 "Non-Pedagogy Session" 2 "Pedagogy Session" 3 "Homework" 3 "Review" 5 "Other"

*Create a pedagogy string variable
gen pedagogy_char = "Non-Pedagogy Sessions" if pedagogy == 0
replace pedagogy_char = "Pedagogy Sessions" if pedagogy == 1
replace pedagogy_char = "Homework" if pedagogy == 2
replace pedagogy_char = "Review" if pedagogy == 3
replace pedagogy_char = "Orientation" if pedagogy == 4
replace pedagogy_char = "Other" if pedagogy == 5
label values pedagogy_char order

levelsof pedagogy_char, local(peda)
*/

global names Henrico Henry LC Portland SLC WC

capture drop dnum
encode district, gen(dnum)
set more off

local k = 1

foreach v in $names {

preserve

keep if dnum == `k'

collapse (sum) lengthmin, by(session_mod pedagogy)

tabstat lengthmin, statistics(count sum mean sd min max) save
matrix T = r(StatTotal)
matrix T_t = (T)'


tab pedagogy,m 
local i = r(r)

tabstat lengthmin, by(pedagogy) statistics(count sum mean sd min max) save

	forvalues x = 1/`i' {
	
	matrix A = r(Stat`x')

	if `x' == 1 {
	matrix B = A
	}
	
	else {
	matrix B = (B,A)
	}
	
	}

	matrix C = (B)'\ T_t
	
	
	if `i' == 5 {
	matrix rownames C =  "Non-Pedagogy Session" "Pedagogy Session" "Homework" "Review" "Other" "Overall"
	*Henry doesn't have an orientation session. 
	}
	
	if `i' == 6 {
	matrix rownames C = "Non-Pedagogy Session" "Pedagogy Session" "Homework" "Review" "Orientation" "Other" "Overall"
	}
	
	
	matrix colnames C =  "N of Sessions" "Sum of Session Lengths" "Mean Length of Sessions" "SD" "Minimum Session Length" "Maximum Session Length"
	matlist C
	

	if `k' == 1 {
	xml_tab C, save("exhibit3.xls") sheet(`v') replace
	} 
	
	else {
	xml_tab C, save("exhibit3.xls") sheet(`v') append
	}
	*/

restore

local k = `k' + 1

}



****Exhibit 4: Length of Activities by Session Type, Minutes *******

	global names Henrico Henry LC Portland SLC WC

	matrix define X = J(36,6,.)

	capture drop dnum
	encode district, gen(dnum)
	set more off

	local k = 1

	foreach v in $names {

	preserve
	keep if dnum == `k'

	collapse (sum) lengthmin, by(activity pedagogy session_mod)
	levelsof pedagogy, local(session)

	tabstat lengthmin, statistics(count sum mean sd min max) save
	matrix T = r(StatTotal)
	matrix T_t = (T)'


		foreach y  in `session' {

		levelsof pedagogy if pedagogy == `y', local(peda)
		levelsof activity if pedagogy == `y', local(activ)
		
		matrix define Y = J(1,6,.)
		matrix rownames Y = `peda'
		
		/*
		local i = 1
		foreach w in `activ' {
		
		global r "p`peda' `w'"
		if `i' == 1 {
		global j  "$r"
		}
		if `i' != 1 {
		global j  "$j $r"
		}

		local i = `i' + 1
		}
		dis "$j"
		*/
		
		tab activity if pedagogy == `y',m 
		local i = r(r)

		tabstat lengthmin if pedagogy == `y', by(activity) statistics(count sum mean sd min max) save

				forvalues x = 1/`i' {
				
				*global r "`peda' `r(name`x')'"
				
				matrix A`y' = r(Stat`x')
					
					
				if `x' == 1 {
				matrix B`y' = A`y'
				*global ro "$r"
				
				}
		
				else {
				matrix B`y' = (B`y',A`y')
				*global ro "$ro "$r""
				}
		
			}
			
		matrix C`y' = (B`y')'	
		matrix rownames C`y' = `activ'
		
		matrix D`y' = Y\C`y'
			
		}
		
	*levelsof pedagogy, local(total)	
		
		foreach x  in `session' {
		
		if `x' == 0 {
		mat E = D`x'
		matlist E
		}
		
		else {
		mat E = (E \ D`x')
		matlist E
		}
		
		}
		
		*Add the overall data
		mat F = E\T_t
		
		if `k' == 1 {
		xml_tab F, save("exhibit4.xls") sheet(`v') replace
		} 
		
		else {
		xml_tab F, save("exhibit4.xls") sheet(`v') append
		}
		
		restore 
		
		local k = `k' + 1
		
		}
	
	













*summarize overall length of units and sessions
tabstat lengthhrs , by(unit) statistics(sum)
tabstat lengthhrs , by(session) statistics(sum)


*summarize length of activities by type of session
bysort pedagogy: tabstat lengthhrs , by(activity) statistics(sum)

*Get distribution of session lengths
bysort pedagogy: tabstat lengthforcoders , by(session) statistics(sum)

*summarize length by activity and type of session - additional statistics
preserve
collapse (sum) lengthmin lengthhrs, by(session activity pedagogy)

tabstat lengthhrs , by (Session)  statistics(count sum mean sd min max)

bysort pedagogy: tabstat lengthmin , by( activity ) statistics(count sum mean sd min max)
bysort pedagogy: tabstat lengthhrs , by( Activity ) statistics(count sum mean sd min max)

restore


*summarize active instruction length by pedagogy, distribution by session

preserve
collapse (sum) lengthmin lengthhrs lengthforcoders, by(Session pedagogy)

tabstat lengthmin , by(pedagogy) statistics(count sum mean sd min max)
tabstat lengthforcoders , by(pedagogy) statistics(count sum mean sd min max)

restore

