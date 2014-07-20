rm -rf tmp
for THREADCOUNT in 2 3 4 6 8 11 16 23 32 45 64 91 128 181 256
do
  jmeter.sh -n -t plan.jmx -Juser.dir=`pwd` -Jthreads=$THREADCOUNT
done