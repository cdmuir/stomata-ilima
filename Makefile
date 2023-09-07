# A good simple tutorial about Make can be found at http://kbroman.org/minimal_make/ 
R_OPTS=--no-save --no-restore --no-init-file --no-site-file
all: data model paper
data: processed-data/licor.rds processed-data/site.rds processed-data/trait.rds dryad/stomata-ilima.csv
model: objects/fit_licor.rds objects/fit_stomata.rds objects/fit_thickness.rds
paper: ms/ms.pdf ms/si.pdf

ms/ms.pdf: ms/ms.qmd ms/stomata-ilima.bib figures/habitat-aa.pdf figures/habitat-Ags.pdf figures/habitat-gmaxratio.pdf figures/licor.pdf figures/pp-licor.pdf figures/traits-aa.pdf processed-data/licor.rds objects/fit-licor.rds objects/fit_stomata.rds objects/fit_thickness.rds objects/habitat_aa.rds objects/habitat_aa1.rds objects/coef_thickness_aa.rds objects/gmaxratio_sitetype.rds objects/coef_gmaxratio_aa.rds objects/fit_habitat_Ags.rds objects/sum_data.rds r/header.R r/functions.R
	quarto render ms/ms.qmd
	quarto render ms/si.qmd

figures/habitat-aa.pdf: processed-data/site.rds objects/aa.rds
	Rscript -e 'source("r/08_plot-habitat-aa.R")'
	
figures/habitat-Ags.pdf: processed-data/site.rds processed-data/licor.rds
	Rscript -e 'source("r/13_plot-habitat-Ags.R")'

figures/habitat-gmaxratio.pdf: processed-data/site.rds objects/gmaxratio_site.rds objects/gmaxratio_ind.rds
	Rscript -e 'source("r/11_plot-habitat-gmaxratio.R")'

figures/licor.pdf: processed-data/site.rds objects/fit_licor.rds objects/aa.rds processed-data/licor.rds
	Rscript -e 'source("r/07_plot-licor.R")'

figures/pp-licor.pdf: objects/fit_licor.rds
	Rscript -e 'source("r/15_plot-pp-licor.R")'

figures/traits-aa.pdf: objects/plot_gmaxratio_aa.rds objects/plot_thickness_aa.rds
	Rscript -e 'source("r/14_plot-traits-aa.R")'

processed-data/licor.rds: processed-data/site.rds raw-data/licor/2022-08-07-0716_logdata raw-data/licor/2022-08-14-0802_logdata raw-data/licor/2022-08-18-1554_logdata raw-data/licor/2022-08-19-0745_logdata raw-data/licor/2022-08-19-1038_logdata raw-data/licor/2022-08-19-1311_logdata raw-data/licor/2022-08-20-1051_logdata raw-data/licor/2022-08-20-1318_logdata raw-data/licor/2022-08-28-0644_logdata raw-data/licor/2022-09-18-0818_logdata raw-data/licor/2022-10-09-0956_logdata raw-data/licor/2022-11-20-0721_logdata raw-data/licor/2022-11-25-0852_logdata
	Rscript -e 'source("r/03_process-licor.R")'

objects/fit-licor.rds: processed-data/licor.rds
	Rscript -e 'source("r/04_fit-licor.R")'

objects/fit_stomata.rds: processed-data/trait.rds
	Rscript -e 'source("r/05_fit-traits.R")'

objects/fit_thickness.rds: processed-data/trait.rds
	Rscript -e 'source("r/05_fit-traits.R")'

objects/aa.rds: processed-data/licor.rds objects/fit_licor.rds
	Rscript -e 'source("r/06_estimate-aa.R")'

objects/habitat_aa.rds: processed-data/site.rds objects/aa.rds
	Rscript -e 'source("r/08_plot-habitat-aa.R")'
	
objects/habitat_aa1.rds: processed-data/site.rds objects/aa.rds
	Rscript -e 'source("r/08_plot-habitat-aa.R")'

objects/coef_thickness_aa.rds: processed-data/site.rds objects/aa.rds objects/fit_thickness.rds
	Rscript -e 'source("r/09_plot-thickness-aa.R")'
	
objects/plot_thickness_aa.rds: processed-data/site.rds objects/aa.rds objects/fit_thickness.rds
	Rscript -e 'source("r/09_plot-thickness-aa.R")'

objects/gmaxratio_sitetype.rds: processed-data/site.rds objects/aa.rds objects/fit_stomata.rds
	Rscript -e 'source("r/10_calculate-gmaxratio.R")'

objects/gmaxratio_site.rds: processed-data/site.rds objects/aa.rds objects/fit_stomata.rds
	Rscript -e 'source("r/10_calculate-gmaxratio.R")'

objects/coef_gmaxratio_aa.rds: objects/aa.rds objects/gmaxratio_ind.rds objects/gmaxratio_leaf.rds processed-data/trait.rds
	Rscript -e 'source("r/12_plot-gmaxratio-aa.R")'

objects/plot_gmaxratio_aa.rds: objects/aa.rds objects/gmaxratio_ind.rds objects/gmaxratio_leaf.rds processed-data/trait.rds
	Rscript -e 'source("r/12_plot-gmaxratio-aa.R")'

objects/fit_habitat_Ags.rds: processed-data/site.rds processed-data/licor.rds
	Rscript -e 'source("r/13_plot-habitat-Ags.R")'

objects/sum_data.rds: processed-data/trait.rds objects/site_Ags.rds
	Rscript -e 'source("r/16_archive-data.R")'

objects/fit_licor.rds: processed-data/licor.rds
	Rscript -e 'source("r/04_fit-licor.R")'

objects/site_Ags.rds: processed-data/site.rds processed-data/licor.rds
	Rscript -e 'source("r/13_plot-habitat-Ags.R")'

processed-data/site.rds: raw-data/site.csv
	Rscript -e 'source("r/02_process-trait-data.R")'

processed-data/trait.rds: raw-data/leaf_thickness.csv raw-data/licor_leaf.csv raw-data/plant.csv raw-data/site.csv raw-data/stomata_density.csv raw-data/stomata_size.csv
	Rscript -e 'source("r/02_process-trait-data.R")'

dryad/stomata-ilima.csv: processed-data/trait.rds objects/site_Ags.rds
	Rscript -e 'source("r/16_archive-data.R")'
	
clean: 
	\rm -f *~ *.Rout */*~ */*.Rout .RData Rplots.pdf
	
cleanall: 
	\rm -f *.aux *.bbl *.blg *.log *.pdf *~ *.Rout */*~ */*.Rout ms/ms.pdf ms/ms.tex ms/si.pdf ms/si.tex objects/*.rds objects/*.csv processed-data/*.rds */*.aux */*.log 
	\rm -f dryad/stomata-ilima.csv
	\rm -f figures/habitat-aa.pdf
	\rm -f figures/habitat-Ags.pdf
	\rm -f figures/habitat-gmaxratio.pdf
	\rm -f figures/habitat-aa.pdf
	\rm -f figures/licor.pdf
	\rm -f figures/pp-licor.pdf
	\rm -f figures/traits-aa.pdf
