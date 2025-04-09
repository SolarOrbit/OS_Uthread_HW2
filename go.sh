cd xv6
make clean
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
bash run.sh
