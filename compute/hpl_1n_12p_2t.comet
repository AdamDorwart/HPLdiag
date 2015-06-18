#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=24
#SBATCH --time=00:37:00
#SBATCH --job-name=HPL_1n_12p_2t
#SBATCH --output="./results/HPL_1n_12p_2t.%j.%N.out"
#SBATCH --error="./results/HPL_1n_12p_2t.%j.%N.err"
#SBATCH --export=ALL

cd compute
echo "------------HPL CPU Test-------------------"

tstart=`date +%s` # Starting timestamp

# Set time limit for HPL execution to slurm wall times minus 240 seconds
tlimit=1980

# This is the HPL.24.P2.Q6.N117824.dat HPL.dat  problem
# run on 1 node, 12 MPI processes and 2 threads per MPI process

### Setup the environment:
module load intel mvapich2_ib
export OMP_NUM_THREADS=2

# Execute code and set time limit using timeout
timeout $tlimit ibrun -v -np 12 ./xhpl.cpu
timeout_code=$?

npass=`grep PASSED ../results/$SLURM_JOB_NAME.$SLURM_JOB_ID.*.out | wc --lines`
nfail=`grep FAILED ../results/$SLURM_JOB_NAME.$SLURM_JOB_ID.*.out | wc --lines`
tinterval=`grep WR11C2R4 ../results/$SLURM_JOB_NAME.$SLURM_JOB_ID.*.out | awk '{print $6}'`

if [ $timeout_code = '124' ]; then                  # Did job timeout?
    result="HPL-CPU-TIMEOUT"
    code=1
elif (( $npass == 0 )) && (( $nfail == 0)); then    # Did job die (fail to return answer)?
    result="HPL-CPU-DIED"
    code=1
elif (( $npass > 0 )) && (( $nfail == 0)); then     # Did job give correct answer?
    result="HPL-CPU-PASS"
    code=0
else                                                # If we got here, found wrong answer
    result="HPL-CPU-FAIL"
    code=1
fi

tend=`date +%s` # Ending timestamp

echo "$SLURM_JOB_ID $tstart $tend $SLURM_JOB_NODELIST $tinterval $result" >> ../log/HPLresults.$1

echo "------------FIO SSD Test-------------------"
awk -v user="$USER" -v jobid="$SLURM_JOB_ID" '{ gsub("%USER%",user); gsub("%JOBID%",jobid); print}' ./ssd-test.fio >> ssd-test.$SLURM_JOB_ID
./fio --output-format=json ssd-test.$SLURM_JOB_ID
rm ssd-test.$SLURM_JOB_ID


exit $code
