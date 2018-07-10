****Updated HLM Analyses Assessing FY2 Impacts for Cohort 1 Schools (with 2012-13 CCD)**
//////////////////////////////////////////////////////////////////////////////////
***Random-effects model estimating overall impact on change from baseline to FY2 (CO + IN)**
****Need to drop FY1 data from this analysis****
set more off
cd "H:\share\NMSI I3\Data\Analyses\Mengli"
use NMSI_C1_Y2_for_HLM, clear
drop if year==13 

tempfile save
save `save', replace

forvalues j= 0 1 to 2 {
use `save', clear
local listofcovariates MSE_TAKE MS_TAKE MATH_TAKE SCI_TAKE ENG_TAKE MSE_PASS MS_PASS MATH_PASS SCI_PASS ENG_PASS
order `listofcovariates', first
local numvars : word count `listofcovariates'
forvalues i=1 2 to `numvars' {
local v`i' : word `i' of `listofcovariates'
label var `v`i'' "`v`i''"
rename `v`i'' v`i'_`v`i''
rename v`i'* V`i'
local lab`i' : variable label V`i'

putexcel B2=("Coef.") C2=("SE")  D2=("z") E2=("p-value") 										using "Table 4-1-15", modify 


if inlist("`i'","1","2","3","4","5") {
local num 3
putexcel A`=(3)+(`j'*14)'=("Percent Taking AP Exam") 											using "Table 4-1-15", modify 
}
if inlist("`i'","6","7","8","9","10") {
putexcel A`=(9)+(`j'*14)'=("Percent Passing AP Exam") 											using "Table 4-1-15", modify 
local num 4
}

if inlist("`j'","0") {
local outcomelocal FY2_treat
putexcel A`=(2)+(`j'*14)'=("Overall (CO+IN)") 													using "Table 4-1-15", modify 
}
if inlist("`j'","1") {
local outcomelocal FY2_CO_treat
putexcel A`=(2)+(`j'*14)'=("Colorado") 														using "Table 4-1-15", modify 
}
if inlist("`j'","2") {
local outcomelocal FY2_IN_treat
putexcel A`=(2)+(`j'*14)'=("Indiana") 															using "Table 4-1-15", modify 
}

if inlist("`j'","0") {

    xtmixed V`i' treat FY2 MEMBER2011 FRL_P_2011 WHITE_P_2011 suburb11 rural11 CO ///
        FY2_treat FY2_member11 FY2_frpl11 FY2_white11 FY2_suburb11 FY2_rural11 FY2_CO || ncessch: FY2, reml var
}

if inlist("`j'","1","2") {

   xtmixed V`i'  CO CO_treat IN_treat MEMBER2011 FRL_P_2011 WHITE_P_2011 suburb11 rural11 ///
    FY2 FY2_CO FY2_CO_treat FY2_IN_treat  FY2_member11 FY2_frpl11 FY2_white11 FY2_suburb11 FY2_rural11|| ncessch: FY2, reml var 
}
			
putexcel A`=(`i'+`num')+(`j'*14)'=("`lab`i''") 													using "Table 4-1-15", modify 	
putexcel B`=(`i'+`num')+(`j'*14)'=((_b[`outcomelocal'])) 										using "Table 4-1-15", modify 
putexcel C`=(`i'+`num')+(`j'*14)'=((_se[`outcomelocal'])) 										using "Table 4-1-15", modify 
putexcel D`=(`i'+`num')+(`j'*14)'=((_b[`outcomelocal'])/(_se[`outcomelocal'])) 					using "Table 4-1-15", modify 
putexcel E`=(`i'+`num')+(`j'*14)'=(2*(1-normal(abs(_b[`outcomelocal']/_se[`outcomelocal'])))) 	using "Table 4-1-15", modify 


}
}




