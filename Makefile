#AUS_PAC=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list) ) )

AUS_PAC_DSF_FILES=$(shell cat aus_pacific_tile_list)
AUS_PAC_OVERLAYS=$(addprefix Ortho4XP/yOrtho4XP_Overlays/*/*/, $(AUS_PAC_DSF_FILES) )

#AUS_PAC_DSF_FILES=$(shell head -n 25 aus_pacific_tile_list)
AUS_PAC_TILES_0=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list.00) ) )
AUS_PAC_TILES_1=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list.01) ) )
AUS_PAC_TILES_2=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list.02) ) )
AUS_PAC_TILES_3=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list.03) ) )

all:
	echo ""

ortho4xp.diff:
	cd Ortho4XP && git diff > ../ortho4xp.diff

Ortho4XP:
	git clone --depth=1 https://github.com/oscarpilote/Ortho4XP.git
	cd $@ && patch -p1 -u < ../ortho4xp.diff
	cp extract_overlay.py $@/.

%_chunks: %
	split $< -d -l 500 $<.

#
# Overlay setup
#

Ortho4XP/yOrtho4XP_Overlays/*/*/%.dsf: Ortho4XP
	@echo "Make overlay $@"
	set -e;\
	export COORDS=$$(echo $@ | sed -e 's|.*/\([-+][0-9]\+\)\([-+][0-9]\+\).dsf|\1 \2|g');\
 	cd $< && python3 extract_overlay.py $$COORDS

y_aus_pac: $(AUS_PAC_OVERLAYS)
	mkdir -p $@

%_overlays.zip: %
	cp -r Ortho4XP/yOrtho4XP_Overlays $</.
	zip -r $@ $<

#
# Tile pack setup
#

Ortho4XP/Tiles/zOrtho4XP_%: Ortho4XP
	@echo "Make tile $@" 
	set -e;\
	export COORDS=$$(echo $@ | sed -e 's/.*_\([-+][0-9]\+\)\([-+][0-9]\+\)/\1 \2/g');\
 	cd $< && python3 Ortho4XP_v130.py $$COORDS BI 16

z_aus_pac_0: $(AUS_PAC_TILES_0)
z_aus_pac_1: $(AUS_PAC_TILES_1)
z_aus_pac_2: $(AUS_PAC_TILES_2)
z_aus_pac_3: $(AUS_PAC_TILES_3)

z_%.zip: z_%
	mkdir -p $<
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/'Earth nav data' $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/terrain $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/textures $</.
	cp ORTHO_SETUP.md $</.
	zip -r $@ $<

clean:
	-rm -rf Ortho4XP/Tiles
	-rm -rf Ortho4XP/yOrtho4XP_Overlays
	-rm *.zip
	-rm -rf z_aus_pac
