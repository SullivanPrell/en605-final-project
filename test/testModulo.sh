#/bin/bash

pushd bin
echo "---- Modulo test ----"
for i in $(seq 1 49)
do
	for j in $(seq 1 49)
	do
		echo -n -e "$i % $j =\t"
		./mod << EOF
$i
$j
EOF
	done
done
popd