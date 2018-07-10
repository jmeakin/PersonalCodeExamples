
* Create a local (LOCAL) that lists files

foreach file in `LOCAL' {
clear
use "`file'"

capture append using `master'

tempfile master
save `master'
clear
}


use `master'
