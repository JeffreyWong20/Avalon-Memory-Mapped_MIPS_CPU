TESTCASES="./assembly/*.txt"

mkdir ./results

for i in ${TESTCASES} ; do
	
	PATTERN='assert v0 = '
	NOTHING=""
	TESTNAME=$(basename ${i})
	TEST=$(basename ${i} .txt)
	
	# Use "grep" to look only for lines containing PATTERN
	set +e
	grep "^${PATTERN}" ./assembly/${TESTNAME} > ./results/${TESTNAME}
	set -e
	# Use "sed" to replace "CPU : OUT   :" with nothing
	
	sed "s/${PATTERN}/${NOTHING}/" ./results/${TESTNAME} > ./results/expected/CPU_testbench_${TEST}_expected.txt
	#echo ${TESTNAME}		
done
