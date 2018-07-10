set more off
clear
capture program drop excelcombine
program define excelcombine
	args directory type strings
	cd "`directory'"
	local files : dir . files "`strings'.`type'"
	local files2 "~"
	foreach f in `files' {
		if strpos("`f'","~") {
			local files2 `files2'
		}
		else {
			local files2 `files2' "`f'"
		}
	}
	local files : subinstr local files2 "~" "" 
	local numfiles : word count `files'
	forvalues i=1/`numfiles' {
		local file`i': word `i' of `files'
	}
	forvalues i=1/`numfiles' {
		import excel using "`file`i''", describe
			forvalues j=1/`=r(N_worksheet)' {
				import excel using "`file`i''", describe
				local sheet `r(worksheet_`j')'
				import excel using "`file`i''", sheet(`r(worksheet_`j')') allstring clear
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
	
cd "\\tx1cifs\tx1data\Austin Share\CLI ScaleUp Grant\Implementation 2016-17\Data\Updated Implementation Data"
local folders : dir . dirs "*"
local numfolders : word count `folders'
forvalues i=1/`numfolders' {
	local folder`i': word `i' of `folders'
}
forvalues i=1/`numfolders' {
	excelcombine "\\tx1cifs\tx1data\Austin Share\CLI ScaleUp Grant\Implementation 2016-17\Data\Updated Implementation Data\\`folder`i''" xlsx *Roster*
	tempfile dist`i'
	save `dist`i''
}
clear
forvalues i=1/`numfolders' {
	append using `dist`i''
}








	




