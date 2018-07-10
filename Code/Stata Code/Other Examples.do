
set more off
set linesize 255

global curpath    "H:/share/REL Midwest EWIMS/Secure Data/2 Administrative Data/Student Level Data/work/withrow" 
global curauthor  "cblankenship" 
global curdate    "2014.09.22" 

///log using "$curpath\mk_student.log", replace

display  "$curauthor   $curdate    $curpath"
/// +---------------------------------------------------------------------------+ 
/// | notes:                                                                    |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// |                                                                           |
/// +---------------------------------------------------------------------------+



/// files 

local  t1_s1 = "$curpath/student Id_withrow_NEW.csv" 
local  t1_s2 = "$curpath/Ell information2.csv"     
local  t1_s3 = "$curpath/race and address_withrow.csv" 
local  t1_s4 = "$curpath/School entry date_withrow.xls" 
local  t1_s5 = "$curpath/discipline2.csv" 
local  t1_s6 = "$curpath/credits and gpa_withrow.xls" 
local  t1_s7 = "$curpath/withrow grades2.csv" 
local  t1_s8 = "$curpath/WITHROW TEST SCORES2.csv" 

        
forval i=1/8 {
    
                
        display "`t1_s`i''"       
                               
            
        if inlist("`i'","4","6"){
            import excel using "`t1_s`i''", allstring firstrow clear
            }
        else{
            import delimited "`t1_s`i''" 
            }
        
        describe
        
        if (`i' == 1){
            rename id ssid
            }
        if (`i' == 2){
            rename studentid ssid 
            }
        if (`i' == 3){
            rename studentid ssid
            }
        if (`i' == 4){
            rename entrydate DistrictEntry
            
            gen long ssid = real(StudentId)
            drop StudentId                      
            }
        if (`i' == 5){
            rename v1 ssid
            
            keep if strpos(disciplineactiondate,"2013") == strpos(disciplineactiondate,"2014") == 0
            
            gen InSchoolSuspensions    = (disciplineactiontaken  ==  "2")           
            gen OutOfSchoolSuspensions = (disciplineactiontaken  ==  "3")                        
            gen Expulsions             = (disciplineactiontaken  ==  "7")            
            gen Detentions             = (disciplineactiontaken  == "13")            
            gen DisciplineOther        = (!missing(disciplineactiontaken))
            
            * this next line sums these variables up to the student level ; 
            collapse (sum) InSchoolSuspensions OutOfSchoolSuspensions Expulsions Detentions DisciplineOther, by(ssid) 
            }
        if (`i' == 6){
            rename WEIGPA gpa            
            rename CreditsEarned cumulativecredits             
            
            * convert ssid from string to numeric so it matches the format of other files ; 
            gen long ssid = real(ID)
            drop ID 
            }
        if (`i' == 7){
            duplicates drop 
        
            rename potentialcrhrs potentialcredits
            rename course_name coursename      
            rename grade coursegrade 
            rename student_number ssid         
                                        
            }
        if (`i' == 8){
            duplicates drop 
        
            rename student_number ssid
            
            gen yr = reverse(substr(reverse(test_date),1,4))   
            keep testscorename ssid numscore yr
            
            keep if (numscore>0)
            keep if inlist(testscorename,"OAT08_MATH", "OAT08_READING") 
            keep if inlist(yr,"2013","2014")
            
            * we want to transpose the testscore results from stacked (tall) to side by side (wide) format ; 
            reshape wide numscore, i(ssid yr) j(testscorename) string            
            
            rename numscoreOAT08_MATH gr8_Math_2013
            rename numscoreOAT08_READING gr8_Read_2013
            
            keep ssid gr8*
            
            }        
        
        sort ssid
        save `i', replace
                                
        clear        
        
}

use 1
merge 1:1 ssid using 2 
drop _merge
merge 1:1 ssid using 3
drop _merge
merge 1:1 ssid using 4
drop _merge
merge 1:1 ssid using 5
drop _merge
merge 1:1 ssid using 6
drop _merge
merge 1:1 ssid using 8
drop _merge

merge 1:m ssid using 7
drop _merge

describe 

keep ssid dateofbirth gender ell raceethnicity disability Grade DistrictEntry ///
     InSchoolSuspensions OutOfSchoolSuspensions Expulsions Detentions gpa  ///
    cumulativecredits potentialcredits coursename coursegrade gr8_Read_2013 gr8_Math_2013  


save withrow_baseline, replace 

clear

