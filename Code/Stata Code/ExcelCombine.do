capture program drop excelcombine
program define excelcombine
	args directory type
	cd "`directory'"
	local files : dir . files "*.`type'"
	local numfiles : word count `files'
	forvalues i=1/`numfiles' {
		local file`i': word `i' of `files'
	}
	forvalues i=1/`numfiles' {
		import excel using "`file`i''", describe
			forvalues j=1/`=r(N_worksheet)' {
				import excel using "`file`i''", describe
				local sheet `r(worksheet_`j')'
				import excel using "`file`i''", sheet(`r(worksheet_`j')') firstrow allstring clear
				gen Sheet="`sheet'"
				tempfile sheet`j'
				save `sheet`j'', replace
			}
		
		clear
		import excel using "`file`i''", describe
		forvalues j=1/`=r(N_worksheet)' {
			append using `sheet`j''
		}
		gen File="`file`i''"
		tempfile f`i'
		save `f`i'', replace
	}
	clear
	forvalues i=1/`numfiles' {
	append using `f`i''
	}
	end

cd "H:\share\CLI i3 ScaleUp\3 Data Collection\Teachers\1. Fall 2016 Teacher Survey\Data"
import excel "Survey results_raw data4", clear
foreach v of varlist* {
replace `v'="</span>"+`v' if strpos(`v',"</span>")==0
split `v', p("</span>")
}
keep in 1


	
excelcombine "H:\share\CLI i3 ScaleUp\3 Data Collection\Teachers\1. Fall 2016 Teacher Survey\Data" xls




