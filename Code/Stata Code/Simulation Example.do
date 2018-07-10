
program define xbaruniform, rclass
syntax[, n(integer 100) a(real 0) b(real 1) null(real .5)]
drop _all
set obs `n'
gen draws = runiform()*(1/(`b'-`a'))+`a'
qui sum draws
return scalar xbar = r(mean)
return scalar tstat = (r(mean)-`null')/(r(sd)/sqrt(`n'))
end
simulate samplemean=r(xbar) tstat=r(tstat), reps(1000) seed(12345678) : xbaruniform

sum samplemean
hist tstat
