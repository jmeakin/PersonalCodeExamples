set obs `=_N + 1'
ds, has(type numeric)

qui foreach v in `r(varlist)' {
su `v', meanonly
replace `v' = r(mean) in L
}
