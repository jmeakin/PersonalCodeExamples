
set more off
clear
set obs 1000
egen dist=seq(), from(1) to(100)
gen school=_n
gen member=round(runiform()*100)
gen frl=runiform()



* Just to see what the returns are
_pctile frl [fw=member] if dist==1, percentiles(20 80) 
return list
return clear

gen top20=.
gen bottom20=.
gen pcttop20=.
gen pctbottom20=.

levelsof dist, local(ids)
foreach id in `ids' {

_pctile frl [fw=member] if dist==`id', percentiles(20 80) 

replace top20=1 if frl>=r(r2) &  dist==`id'
replace bottom20=1 if frl<=r(r1) &  dist==`id'

replace pcttop20=r(r2) if dist==`id'
replace pctbottom20=r(r1) if dist==`id'


}

sort dist
browse

egen quatile=xtile(frl), by (dist) weights(member) n(5) 
