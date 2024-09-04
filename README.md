# stomata-ilima

This repository contains source code associated with the manuscript:

Amphistomy increases leaf photosynthesis more in coastal than montane plants of Hawaiian ʻilima (*Sida fallax*). 2024. *The American Journal of Botany*. 111(2):e16284.

## Author contributions

Genevieve Triplett and [Chris Muir](https://cdmuir.netlify.app) contributed equally to all stages of this project; [Tom Buckley](https://buckleylab.ucdavis.edu/) contributed to development of the method and helped edit the manuscript.

## Contents

This repository has the following file folders:

- `figures`: figures generated from original artwork and *R* code
- `objects`: saved objects generated from *R* code
- `processed-data`: processed data generated from *R* code
- `ms`: manuscript input (e.g. `ms.qmd`, `si.qmd` and `stomata-ilima.bib`) and output (e.g. `ms.pdf`, `si.pdf`) files
- `r`: *R* scripts for all data processing and analysis
- `raw-data`: raw data files

## Prerequisites:

To run code and render manuscript:

- [*R*](https://cran.r-project.org/) version >4.3.0 and [*RStudio*](https://www.posit.co/) (recommended)
- [LaTeX](https://www.latex-project.org/): you can install the full version or try [**tinytex**](https://yihui.org/tinytex/)
- [GNU Make](https://www.gnu.org/software/make/): In terminal, you can just type `make paper` to render the manuscript. You can also use it to re-run all scripts.

Before running scripts, you'll need to install the following *R* packages:

```
source("r/install-packages.R")
```

To fit **brms** model, set up [**cmdstanr**](https://mc-stan.org/cmdstanr/).

## Downloading data and code 

1. Download or clone this repository to your machine.

```
git clone git@github.com:cdmuir/stomata-ilima.git
```

2. Open `stomata-ilima.Rproj` in [RStudio](https://www.posit.co/)

## Rendering manuscript

### Software requirements

At minimum, you will need [R](https://cran.r-project.org/) version 4.3.0 or greater installed on your machine. Install additional packages by running `r/install-packages.R`.

### Rendering manuscript with pre-saved outout

Open `ms/ms.qmd` and knit using [RStudio](https://www.posit.co/).

You can also run the following code from the terminal:

```{terminal}
quarto render ms/ms.qmd
quarto render ms/si.qmd
```

or use `make`

```
make paper
```

### Generating all results

You can re-run all analyses, figures, etc. using [GNU make](https://www.gnu.org/software/make/). Type `make --version` in a terminal/shell to see if it is already installed.

```
# Clear out previously saved output
make cleanall
# This will take a long time to run
make
```
