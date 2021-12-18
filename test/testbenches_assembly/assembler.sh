TESTCASES="./assembly/*.txt"

mkdir ./hex

for i in ${TESTCASES} ; do
	
	PATTERN='0x'
	NOTHING=""
	TESTNAME=$(basename ${i})
	# Use "grep" to look only for lines containing PATTERN
	set +e
	grep "^${PATTERN}" ./assembly/${TESTNAME} > ./hex/${TESTNAME}
	set -e
	# Use "sed" to replace "CPU : OUT   :" with nothing
	sed "s/${PATTERN}/${NOTHING}/" ./hex/${TESTNAME} > ./hex/machine_code/${TESTNAME}
	#echo ${TESTNAME}		
done
