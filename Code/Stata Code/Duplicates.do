sort StudentID
by StudentID: gen dup=cond(_N==1,0,_n)
tab dup
drop if dup>0
