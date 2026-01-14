# Scripts to perform GONE2 analysis on each Leatherback turtle population.
---
## 1. Convert VCF files to PLINK .map and .ped files
`Slurm script for VCFtools`
```
#!/bin/bash -e

#SBATCH --cpus-per-task  8
#SBATCH --job-name       plinkc
#SBATCH --mem            20G
#SBATCH --time           24:00:00
#SBATCH --account        uoo02423
#SBATCH --output         %x_%j.out
#SBATCH --error          %x_%j.err
#SBATCH --array          1-11

module purge
module load VCFtools/0.1.15-GCC-9.2.0-Perl-5.30.1
module load PLINK/1.09b6.16

# Define the array
declare -a VCF_FILES=(
  "DerCor_eastern_pacific.recode.vcf.gz"
  "DerCor_indowest_pacific.recode.vcf.gz"
  "DerCor_northeast_caribbean.recode.vcf.gz"
  "DerCor_northwest_caribbean.recode.vcf.gz"
  "DerCor_southafrica.recode.vcf.gz"
  "DerCor_southeast_caribbean.recode.vcf.gz"
  "DerCor_westafrica.recode.vcf.gz"
  "DerCor_western_pacific.recode.vcf.gz"
  "DerCor_western_pacific_IND.recode.vcf.gz"
  "DerCor_western_pacific_SI.recode.vcf.gz"
  "DerCor_western_pacific_PAP.recode.vcf.gz"
)

declare -a OUTPUT_PREFIXES=(
  "DerCor_eastern_pacific"
  "DerCor_indowest_pacific"
  "DerCor_northeast_caribbean"
  "DerCor_northwest_caribbean"
  "DerCor_southafrica"
  "DerCor_southeast_caribbean"
  "DerCor_westafrica"
  "DerCor_western_pacific"
  "DerCor_western_pacific_IND"
  "DerCor_western_pacific_SI"
  "DerCor_western_pacific_PAP"
)

# Get the current index from the array job
IDX=$((SLURM_ARRAY_TASK_ID - 1))

# Get the SFS file and output prefix for the current index
VCF_FILE=${VCF_FILES[$IDX]}
OUTPUT_PREFIX=${OUTPUT_PREFIXES[$IDX]}

plink --vcf $VCF_FILE --recode --allow-extra-chr --double-id --out $OUTPUT_PREFIX

```
## 2. Run GONE with unphased diploids option using the ped file and with a genetic map.
`Slurm script for GONE2`
```
#!/bin/bash -e
#SBATCH --cpus-per-task  12
#SBATCH --job-name       GONE2ne
#SBATCH --mem            70G
#SBATCH --time           24:00:00
#SBATCH --account        uoo02423
#SBATCH --output         %x_%j.out
#SBATCH --error          %x_%j.err
#SBATCH --hint           nomultithread

module purge

./gone2 DerCor_southeast_caribbean.ped -g 0 -t 8 -o DerCor_SEC_GONE2


```
