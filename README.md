# PASTEC-singularity

## Description

`Singularity` container for the transposable elements classification tool `PASTEC`(from the package [`REPET`](https://urgi.versailles.inra.fr/Tools/REPET)).


## Dependancies

- `singularity` (tested with v.3.9.5)

## Installation

### Development installation

- Clone this repo:
```
git clone https://github.com/TommasoBarberis/PASTEC-singularity.git
```

- Move to the `PASTEC` directory:
```
cd PASTEC-singularity
```

- To build the `.sif` image from the definition file:
```
sudo singularity build pastec_latest.sif PASTEC.def
```

### Only user installation

- Pull directly the `.sif` image from the [sylabs.io](sylabs.io) registry:

```
singularity pull --arch amd64 library://tommasobarberis98/pastec/pastec:latest
```


## Utilisation

Store your project directory path in a variable:
```
PROJECT_DIR=path/to/project/dir
```

This directory has to contain:
- the `fasta` file with consensi sequences: 

    From the `PASTEC` documentation, each sequence must have 60 bp (or less) by line, so if you have a "one-line" `FASTA` file, you can transform it with the following command:
    ```
    sed '/^>/!s/.\{60\}/&\n/g' oneline.fasta > multiline.fasta
    ```

    About the sequence headers, it is highly advised to write them like this : ">XX_i" with XX standing for letters and i standing for numbers. 

- the `PASTEClassifier.cfg` file (a template is provided with the github repo at the root folder) to update some parameters such as the path to a known database of transposable elements (see more here: [PASTEClassfier-tuto](https://urgi.versailles.inra.fr/Tools/PASTEClassifier/PASTEClassifier-tuto)). Options that you are suggested to update:
    - `project_name`: whatever you want.
    - `TE_nucl_bank`: `/mnt/nucl_bank.fa` such as `repbase20.05_ntSeq_cleaned_TE.fa` (from `RepBase20.05_REPET.embl` require subscription to [girinst](https://www.girinst.org/repbase/)), but you are free to use any other database. Then you can set:
        - `TE_BLRtx`: yes :arrow_right: homology with known TEs using tblastx.
        - `TE_BLRn`: yes :arrow_right: detection of helitron extremities.
    - `TE_prot_bank`: `/mnt/prot_bank.fa` such as `repbase20.05_aaSeq_cleaned_TE.fa` (from `RepBase20.05_REPET.embl` require subscription to [girinst](https://www.girinst.org/repbase/)), but you are free to use any other database. Then you can set:
        - `TE_BLRx`: yes :arrow_right: homology with known TEs using blastx.
    - `HG_nucl_bank`: `/mnt/host_genes.fa` for the cDNA database of the host genes. Then you can set:
        - `HG_BLRn`: yes :arrow_right: homology with host genes.
    - `rDNA_bank`: `/mnt/rdna.fa` for the rDNA database. Then you can set:
        - `rDNA_BLRn`: yes :arrow_right: homology with rDNA.
    - `TE_HMM_profiles`: is already set to the `ProfilesBankForREPET_Pfam32.0.hmm` database, but your are free to use an another database.
    - Adjustable parameters in `[classif_consensus]` section (see [PASTEClassfier-tuto](https://urgi.versailles.inra.fr/Tools/PASTEClassifier/PASTEClassifier-tuto)). 

- the various databases that you can define in the `PASTEClassifier.cfg` file.

### Container initialization

The `PASTEC` program use the `MySQL` database that need to be run as a server, for that you need to initialize the container with this service by creating a singularity instance:
```
bash path/to/init.sh -s pastec_latest.sif -d $PROJECT_DIR
```


### Interactive mode

- Start a shell through the container:
```
cd $PROJECT_DIR
singularity shell instance://pastec
```
- Once in the container, run:
```
python2.7 /opt/PASTEC_linux-x64-2.0/bin/PASTEClassifier.py -i /mnt/consensi.fasta -C /mnt/PASTEClassifier.cfg
```

> **NOTE**: the `/mnt` refer to your `PROJECT_DIR`, so you have to conserve it and you have only to append the file names.

### Batch mode

Create a file `pastec_cmd.sh` (a template is provided in the `test` folder) that will contain the PASTEC command in your project directory (`$PROJECT_DIR`):
```
#! /bin/bash 

python2.7 /opt/PASTEC_linux-x64-2.0/bin/PASTEClassifier.py -i /mnt/consensi.fasta -C /mnt/PASTEClassifier.cfg
```

Then you can run `PASTEC` using the container instance as follow:
```
cd $PROJECT_DIR
singularity exec instance://pastec /mnt/pastec_cmd.sh
```

> **NOTE**: the `/mnt` refer to your `PROJECT_DIR`, so you have to conserve it and you have only to append the file names.

### Other `PASTEC` options

- classification rules file name (e.g. PASTEClassifierRules.yaml) [optional]
 > `-D DECISIONRULESFILENAME`, `--decisionRules=DECISIONRULESFILENAME` 
- step (0/1/2): default: 0 for all steps, step 1 for detect features, step 2 for classification run tool in parallel
> `-S STEP`, `--step=STEP`
- clean temporary files [optional] [default: False]
> `-c`, `--clean`
- verbosity [optional] [default: 3, from 1 to 4]
> `-v VERBOSITY`, `--verbosity=VERBOSITY`