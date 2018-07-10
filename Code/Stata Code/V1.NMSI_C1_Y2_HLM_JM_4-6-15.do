****Updated HLM Analyses Assessing FY2 Impacts for Cohort 1 Schools (with 2012-13 CCD)**
//////////////////////////////////////////////////////////////////////////////////
***Random-effects model estimating overall impact on change from baseline to FY2 (CO + IN)**
****Need to drop FY1 data from this analysis****
set more off
cd "H:\share\NMSI I3\Data\Analyses\Mengli"
use NMSI_C1_Y2_for_HLM, clear
drop if year==13 


local listofcovariates MSE_TAKE MS_TAKE MATH_TAKE SCI_TAKE ENG_TAKE MSE_PASS MS_PASS MATH_PASS SCI_PASS ENG_PASS
order `listofcovariates', first
local numvars : word count `listofcovariates'
forvalues i=1 2 to `numvars' {
local v`i' : word `i' of `listofcovariates'
label var `v`i'' "`v`i''"
rename `v`i'' v`i'_`v`i''
rename v`i'* V`i'
local lab`i' : variable label V`i'

if inlist("`i'","1","2","3","4","5") {
local num 3
}
if inlist("`i'","6","7","8","9","10") {
local num 4
}

putexcel A`=`i'+`num''=("`lab`i''") using "Table 4-1-15", modify 

    xtmixed V`i' treat FY2 MEMBER2011 FRL_P_2011 WHITE_P_2011 suburb11 rural11 CO ///
        FY2_treat FY2_member11 FY2_frpl11 FY2_white11 FY2_suburb11 FY2_rural11 FY2_CO || ncessch: FY2, reml var


putexcel B`=`i'+`num''=((_b[FY2_treat])) 									using "Table 4-1-15", modify 
putexcel C`=`i'+`num''=((_se[FY2_treat])) 									using "Table 4-1-15", modify 
putexcel D`=`i'+`num''=((_b[FY2_treat])/(_se[FY2_treat])) 					using "Table 4-1-15", modify 
putexcel E`=`i'+`num''=(2*(1-normal(abs(_b[FY2_treat]/_se[FY2_treat])))) 	using "Table 4-1-15", modify 

}




foreach var in MSE_TAKE MS_TAKE MATH_TAKE SCI_TAKE ENG_TAKE MSE_PASS MS_PASS MATH_PASS SCI_PASS ENG_PASS {
   xtmixed `var'  CO CO_treat IN_treat MEMBER2011 FRL_P_2011 WHITE_P_2011 suburb11 rural11 ///
    FY2 FY2_CO FY2_CO_treat FY2_IN_treat  FY2_member11 FY2_frpl11 FY2_white11 FY2_suburb11 FY2_rural11|| ncessch: FY2, reml var 
}

log close


