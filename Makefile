PDK ?= gf180mcuD
SCL ?= gf180mcu_as_sc_mcu7t3v3
TILE_LIBRARY ?= tiny

# Get the fabric names
FABRICS :=  $(patsubst fabrics/%,%,$(wildcard fabrics/*)) 

FABRICS_OPENROAD := $(addsuffix -openroad,$(FABRICS))
FABRICS_KLAYOUT := $(addsuffix -klayout,$(FABRICS))
FABRICS_COPY := $(addsuffix -copy,$(FABRICS))

all: $(FABRICS)
.PHONY: all

tiles:
	cd ip/fabulous-tiles/; PDK=${PDK} SCL=${SCL} TILE_LIBRARY=${TILE_LIBRARY} nix develop --command make all
.PHONY: tiles

$(FABRICS):
	librelane --pdk ${PDK} --scl ${SCL} fabrics/$@/config.yaml --save-views-to fabrics/$@/macro/${PDK}/
.PHONY: $(FABRICS)

$(FABRICS_OPENROAD):
	librelane --pdk ${PDK} --scl ${SCL} fabrics/$(subst -openroad,,$@)/config.yaml --last-run --flow OpenInOpenROAD
.PHONY: $(FABRICS_OPENROAD)

$(FABRICS_KLAYOUT):
	librelane --pdk ${PDK} --scl ${SCL} fabrics/$(subst -klayout,,$@)/config.yaml --last-run --flow OpenInKLayout
.PHONY: $(FABRICS_KLAYOUT)

$(FABRICS_COPY):
	# Copy fabric database
	mkdir -p user_designs/fabrics/$(subst -copy,,$@)/macro/${PDK}/
	cp -R fabrics/$(subst -copy,,$@)/macro/${PDK}/fabulous/ user_designs/fabrics/$(subst -copy,,$@)/macro/${PDK}/
	cp fabrics/$(subst -copy,,$@)/constraints.pcf user_designs/fabrics/$(subst -copy,,$@)/constraints.pcf
.PHONY: $(FABRICS_COPY)

tt-fabulous:
	librelane config.yaml --pdk ${PDK} --scl ${SCL} --save-views-to macro/
.PHONY: tt-fabulous

tt-fabulous-openroad:
	librelane config.yaml --pdk ${PDK} --scl ${SCL} --last-run --flow OpenInOpenROAD
.PHONY: tt-fabulous

tt-fabulous-klayout:
	librelane config.yaml --pdk ${PDK} --scl ${SCL} --last-run --flow OpenInKLayout
.PHONY: tt-fabulous

# Copy the files for Tiny Tapeout
tt-fabulous-copy:
	# Copy GDS and LEF
	cp macro/gds/tt_um_fabulous_gf_0p3_3v3.gds gds/tt_um_fabulous_gf_0p3_3v3.gds
	cp macro/lef/tt_um_fabulous_gf_0p3_3v3.lef lef/tt_um_fabulous_gf_0p3_3v3.lef
.PHONY: tt-fabulous-copy
