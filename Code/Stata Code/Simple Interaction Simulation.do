set more off
clear
set obs 1000
gen y=runiform()*10
gen e=rnormal()
gen i=round(runiform(),1)
gen x=(y+e)/3 if i==1
replace x=(y+e)/5 if i==0

reg y x i

gen interact=x*i

* Three ways to run the same model
reg y x i interact
reg y c.x##i.i
reg y x i c.x#i.i

* What i believe you were typing
reg y c.x#i.i
