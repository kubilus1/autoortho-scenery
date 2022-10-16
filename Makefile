#AUS_PAC=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list) ) )

AUS_PAC_DSF_FILES=$(shell head -n 25 aus_pacific_tile_list)
AUS_PAC_TILES=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(AUS_PAC_DSF_FILES) ) )
AUS_PAC_OVERLAYS=$(addprefix Ortho4XP/yOrtho4XP_Overlays/*/*/, $(AUS_PAC_DSF_FILES) )

all:
	echo ""

ortho4xp.diff:
	cd Ortho4XP && git diff > ../ortho4xp.diff

Ortho4XP:
	git clone --depth=1 https://github.com/oscarpilote/Ortho4XP.git
	cd $@ && patch -p1 -u < ../ortho4xp.diff
	cp extract_overlay.py $@/.


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
	zip -s 1G -r $< $<

#
# Tile pack setup
#

Ortho4XP/Tiles/zOrtho4XP_%: Ortho4XP
	@echo "Make tile $@" 
	set -e;\
	export COORDS=$$(echo $@ | sed -e 's/.*_\([-+][0-9]\+\)\([-+][0-9]\+\)/\1 \2/g');\
 	cd $< && python3 Ortho4XP_v130.py $$COORDS BI 16

z_aus_pac: $(AUS_PAC_TILES)
	mkdir -p $@

z_%.zip: z_%
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/'Earth nav data' $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/terrain $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/textures $</.
	cp ORTHO_SETUP.md $</.
	zip -s 1G -r $< $<

clean:
	-rm -rf Ortho4XP/Tiles
	-rm -rf Ortho4XP/yOrtho4XP_Overlays
	-rm *.zip
	-rm -rf z_aus_pac
