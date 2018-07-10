// AIR WORKSHOP
// INTRODUCTION TO MULTILEVEL MODELING IN STATA
// Jordan Rickles, 10.17.14
// revised 10.21.14

clear all

* set directory for workshop files
*cd "G:\stata\mixedworkshop"
cd "\\Dc1fs\dc1ehd\share\Stata Courses\Multilevel Modeling in Stata"

log using "01_AIRworkshop_intro2multilevelmodeling.txt", text replace
//****************************************************************
// EXAMPLE #1
// Introducing the mixed command with a classic two-level example
//****************************************************************

// import data
use http://www.ats.ucla.edu/stat/paperexamples/singer/hsb12, clear
summarize

// unconditional model for math achievement
mixed mathach, || school:, reml stddev
estat icc //calculate icc

// including school-level (level-2) predictors
mixed mathach meanses, || school:, reml
estat icc

// including student-level (level-1) predictors & random-slope
mixed mathach cses, || school: cses, reml cov(un)

* is random slope stat sig based on likelihood ratio test?
estimates store ris //stores results from random slope model
mixed mathach cses, || school:, reml cov(un) // identical model without random slope
estimates store ri //stores results from fixed slope model 
lrtest ris ri //likelihood ratio test

// including both level-1 & level-2 predictors (cross-level interactions)
mixed mathach cses meanses sector meansesBYcses sectorBYcses, || school: cses, reml cov(un)
estat icc


//****************************************************************
// EXAMPLE #2
// A two-level multisite design
//****************************************************************

* import data
use "starexample2.dta", clear
summarize
/* note:
trt = treatment indicator (1=small class size, 0=regular class size)
mtest = 3rd grade math test score
"sm_" = school mean
*/

// 2.1. Does student math achievement differ across schools?
// i.e., Should we account for school-level clustering?

* unconditional two-level model
mixed mtest, || schid:, reml
* note the likelihood ratio test at the bottom of the output
estat icc // how much of the variance is between schools?

// 2.2. Do students have higher math achievement in small classes, on average?

* random intercept model
mixed mtest trt, || schid:, reml
estimates store ri // save estimates for later

// 2.3. Does the small class size effect differ for males and females?
gen trtXfem=trt*female // create interaction term
mixed mtest trt female trtXfem, || schid:, reml

// 2.4. Does the small class size effect differ across schools?
* random intercept & slope model
mixed mtest trt, || schid: trt, reml cov(un)
estimates store ris // save estimates
estat recovariance, correlation

* likelihood ratio test for random slope
lrtest ris ri

* get the level-2 random effects & std errors
predict u1 u0, reffects
predict u1se u0se, reses // standard errors

* get predicted intercepts & slopes
gen b1 = _b[trt] + u1
gen b0 = _b[_cons] + u0

summarize b1 u1 u1se b0 u0 u0se

* graph level-2 random effects
preserve
duplicates drop schid, force
scatter b1 b0
restore

* graph school-level class size effects with standard errors
preserve
duplicates drop schid, force
egen rank1 = rank(b1)
serrbar b1 u1se rank1, scale(1.96) yline(6.8) yline(0)
restore

// 2.5. Is the small class size effect larger in urban schools?
* need to calculate cross-level interaction variables
gen trtXurban = trt*urban
mixed mtest trt urban trtXurban, || schid: trt, reml cov(un)

/* Extra Credit: Is the small class size effect larger in higher poverty schools?
* need to calculate cross-level interaction variables
gen trtXfree = trt*sm_free
mixed mtest trt sm_free trtXfree, || schid: trt, reml cov(un)
*/

//****************************************************************
// EXAMPLE #3
// A three-level model
//****************************************************************

* import data
use "starexample3.dta", clear
summarize

// 3.1. Is there between-teacher, within school variation in math achievement?
mixed mtest, || schid: || tchid:, reml

* note: stata stores the variance components in a strange way.
mat list e(b)
* instead of storing the random effect variance, stata stores the natural log
* of the random effect standard deviation.
* To call the variance components you can do the following:
display exp(_b[lns1_1_1:_cons])^2 // level-3 variance (between-school variance)
display exp(_b[lns2_1_1:_cons])^2 // level-2 variance (between-teacher variance)
display exp(_b[lnsig_e:_cons])^2 // level-1 variance (residual variance)

* we can use these variance components to calculate
* the % of between teacher & between-school variance:
scalar t3 = exp(_b[lns1_1_1:_cons])^2
scalar t2 = exp(_b[lns2_1_1:_cons])^2
scalar s = exp(_b[lnsig_e:_cons])^2

display t3/(t3+t2+s) // proportion between-school variance
display t2/(t3+t2+s) // proportion between-teacher variance

* or we can just ask stata to do the work for us:
estat icc
* but note that for level-2 stata tells us the proportion of level-2 + level 3
* variance.

// 3.2. Does small class size matter?
mixed mtest trt, || schid: || tchid:, reml
estimates store ri3
estat icc

// 3.3. Does the small class size effect differ across schools?
mixed mtest trt, || schid: trt, cov(un) || tchid:, reml

estimates store ris3
lrtest ris3 ri3

* get the level-3 random effects & std errors
* note that now we have to tell stata what random effects level we want
predict u1 u0, reffects relevel(schid)
predict u1se u0se, reses relevel(schid) // standard errors

* graph school-level class size effects with standard errors
preserve
duplicates drop schid, force
egen rank1 = rank(u1)
serrbar u1 u1se rank1, scale(1.96) yline(0)
restore

// 3.3. Does small class size matter more if a teacher was trained?
gen trtXttrain=trt*ttrain
mixed mtest trt ttrain trtXttrain, || schid: || tchid:, reml

/* Extra Credit: Does small class size matter more if a teacher was experienced?
gen trtXtlow=trt*tlowxp
mixed mtest trt tlowxp trtXtlow, || schid: || tchid:, reml
*/

//****************************************************************
// EXAMPLE #4
// A three-level logit model
//****************************************************************

* import data
use "starexample4.dta", clear
summarize
tab hsgrad trt, missing col

* 4.1. Do high school graduation rates differ by elementary school attended?
melogit hsgrad, || schid:

* 4.2. Are students more likely to graduate from high school if they had small classes in elementary school?
melogit hsgrad trt, || schid:,
estimates store ri

* 4.3. Does the effect of small class size differ across schools?
melogit hsgrad trt, || schid: trt, cov(un)

estimates store ris

lrtest ris ri

* get the level-2 random effects & std errors
predict u1 u0, reffects reses(u1se u0se)

* graph level-2 random effects
preserve
duplicates drop schid, force
scatter u1 u0
restore

* graph school-level class size effects with standard errors
* on the logit scale
preserve
duplicates drop schid, force
egen rank1 = rank(u1)
serrbar u1 u1se rank1, scale(1.96) yline(0)
restore

* get predicted probabilities under treatment & control in each school
gen b1 = _b[trt] + u1
gen b0 = _b[_cons] + u0

gen trtprob=exp(b0+b1)/(1+exp(b0+b1))
gen ctrprob=exp(b0)/(1+exp(b0))
gen trtdif=trtprob-ctrprob

* graph distribution of school-level class size effect estimates on probability scale
preserve
duplicates drop schid, force
summarize b1 b0 trtprob ctrprob trtdif
hist trtdif
restore

* graph predicted class size effect on probability scale
* vs. predicted control group probability
preserve
duplicates drop schid, force
scatter trtdif ctrprob
restore

log close
