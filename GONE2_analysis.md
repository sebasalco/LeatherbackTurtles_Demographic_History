# Scripts to perform PSMC analysis on a candidate individual per Leatherback turtle population.
---
## 1. Extract candidate individual per population from global DerCor VCF dataset
`Slurm script for VCFtools`
```
#!/bin/bash -e

#SBATCH --cpus-per-task  1
#SBATCH --job-name       turincl
#SBATCH --mem            20G
#SBATCH --time           24:00:00
#SBATCH --account        uoo02423
#SBATCH --output         %x_%j.out
#SBATCH --error          %x_%j.err
#SBATCH --array          1-11

module purge
module load BCFtools/1.19-GCC-11.3.0
module load VCFtools/0.1.15-GCC-9.2.0-Perl-5.30.1

# Define the array
declare -a POP_FILES=(
  "candidate_eastern_pacific.txt"
  "candidate_southafrica.txt"
  "candidate_western_pacific_IND.txt"
  "candidate_indowest_pacific.txt"
  "candidate_southeast_caribbean.txt"
  "candidate_western_pacific_PAP.txt"
  "candidate_northwest_caribbean.txt"
  "candidate_westafrica.txt"
  "candidate_western_pacific_SI.txt"
  "candidate_northeast_caribbean.txt"
)

declare -a OUTPUT_PREFIXES=(
  "forpsmc_candidate_eastern_pacific"
  "forpsmc_candidate_southafrica"
  "forpsmc_candidate_western_pacific_IND"
  "forpsmc_candidate_indowest_pacific"
  "forpsmc_candidate_southeast_caribbean"
  "forpsmc_candidate_western_pacific_PAP"
  "forpsmc_candidate_northwest_caribbean"
  "forpsmc_candidate_westafrica"
  "forpsmc_candidate_western_pacific_SI"
  "forpsmc_candidate_northeast_caribbean"
)

# Get the current index from the array job
IDX=$((SLURM_ARRAY_TASK_ID - 1))

# Get the SFS file and output prefix for the current index
POP_FILE=${POP_FILES[$IDX]}
OUTPUT_PREFIX=${OUTPUT_PREFIXES[$IDX]}

vcftools --gzvcf \
DerCor_combined_filtered.vcf.gz \
--keep $POP_FILE --remove-indels \
--mac 1 --recode --out $OUTPUT_PREFIX
```
## 2. Convert each candidate individual VCF file to fa.gz using BCFtools.
`Slurm script for BCFtools`
```
#!/bin/bash -e

#SBATCH --cpus-per-task  1
#SBATCH --job-name       FilexPSMC
#SBATCH --mem            15G
#SBATCH --time           24:00:00
#SBATCH --account        uoo02423
#SBATCH --output         %x_%j.out
#SBATCH --error          %x_%j.err
#SBATCH --hint           nomultithread

module purge
module load BCFtools/1.19-GCC-11.3.0

GENOME=/nesi/nobackup/uoo02423/Sebastian/Turtles/Genome/Dcor_sorted_output_good.fasta

for vcf in *final.vcf.gz; do
    prefix="${vcf%.final.vcf.gz}"
    bcftools consensus -f "$GENOME" "$vcf" | gzip > "${prefix}_consensus.fa.gz"
done

```
## 3. Run PSMC array for each candidate individual.
`Slurm script for PSMC`
```
#!/bin/bash -e

#SBATCH --cpus-per-task  2
#SBATCH --job-name       Bt_PSMC
#SBATCH --mem            20G
#SBATCH --time           4-00:00:00
#SBATCH --account        uoo02423
#SBATCH --output         %x_%j.out
#SBATCH --error          %x_%j.err
#SBATCH --hint           nomultithread
#SBATCH --array          1-10

module purge
module load psmc/0.6.5-gimkl-2018b

declare -a POP_FILES=(
  "forpsmc_candidate_eastern_pacific_consensus.fa.gz"
  "forpsmc_candidate_indowest_pacific_consensus.fa.gz"
  "forpsmc_candidate_northeast_caribbean_consensus.fa.gz"
  "forpsmc_candidate_northwest_caribbean_consensus.fa.gz"
  "forpsmc_candidate_southafrica_consensus.fa.gz"
  "forpsmc_candidate_southeast_caribbean_consensus.fa.gz"
  "forpsmc_candidate_westafrica_consensus.fa.gz"
  "forpsmc_candidate_western_pacific_IND_consensus.fa.gz"
  "forpsmc_candidate_western_pacific_PAP_consensus.fa.gz"
  "forpsmc_candidate_western_pacific_SI_consensus.fa.gz"
)

# Get the input file for this array task
INPUT_FQ=${POP_FILES[$SLURM_ARRAY_TASK_ID-1]}
BASE_NAME=$(basename ${INPUT_FQ} .fq)

# Step 1: Convert FASTQ to PSMC format
fq2psmcfa ${INPUT_FQ} > ${BASE_NAME}.psmcfa

# Step 2: Split sequences for bootstrapping
splitfa ${BASE_NAME}.psmcfa > ${BASE_NAME}_split.psmcfa

# Step 3: Run initial PSMC
psmc -N25 -t15 -r5 -d -p "4+25*2+4+6" -o ${BASE_NAME}.psmc ${BASE_NAME}.psmcfa

# Step 4: Run 100 bootstrap replicates
seq 100 | xargs -i echo psmc -N25 -t15 -r5 -b -p "4+25*2+4+6" -o ${BASE_NAME}_round-{}.psmc ${BASE_NAME}_split.psmcfa | sh

# Step 5: Combine results
cat ${BASE_NAME}.psmc ${BASE_NAME}_round-*.psmc > ${BASE_NAME}_bootstrap.psmc

# Step 6: Generate the plot
psmc_plot.pl -R -u 1.2e-08 -g 30 -p ${BASE_NAME}_plot ${BASE_NAME}_bootstrap.psmc

```
