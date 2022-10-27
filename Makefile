AUS_PAC_OVERLAYS=$(addprefix Ortho4XP/yOrtho4XP_Overlays/*/*/, $(shell cat aus_pacific_tile_list) )
NA_OVERLAYS=$(addprefix Ortho4XP/yOrtho4XP_Overlays/*/*/, $(shell cat na_tile_list) )

AUS_PACS:=$(addprefix z_aus_pac_, $(shell ls aus_pacific_tile_list.* | awk -F. '{ print $$2 }') ) 
NAS:=$(addprefix z_na_, $(shell ls na_tile_list.* | awk -F. '{ print $$2 }') ) 

ZIPS=$(addsuffix .zip, $(AUS_PACS))
ZIPS+=$(addsuffix .zip, $(NAS))

# Get the tiles listed in each list file
.SECONDEXPANSION:
AUS_PAC_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list.$* ) ) )
NA_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat na_tile_list.$* ) ) )

y_aus_pac: $(AUS_PAC_OVERLAYS)
	mkdir -p $@

z_aus_pac_%: aus_pacific_tile_list.% $${AUS_PAC_TILES}
	echo "Going to do some $@"

y_na: $(NA_OVERLAYS)
	mkdir -p $@

z_na_%: na_tile_list.% $${NA_TILES}
	echo "Going to do some $@"

#
# Ortho4XP setup
#

ortho4xp.diff:
	cd Ortho4XP && git diff > ../ortho4xp.diff

Ortho4XP:
	git clone --depth=1 https://github.com/oscarpilote/Ortho4XP.git
	cd $@ && patch -p1 -u < ../ortho4xp.diff
	cp extract_overlay.py $@/.

%_chunks: %
	split $< -d -l 300 $<.

#
# Overlay setup
#

Ortho4XP/yOrtho4XP_Overlays/*/*/%.dsf: Ortho4XP
	@echo "Make overlay $@"
	set -e;\
	export COORDS=$$(echo $@ | sed -e 's|.*/\([-+][0-9]\+\)\([-+][0-9]\+\).dsf|\1 \2|g');\
 	cd $< && python3 extract_overlay.py $$COORDS

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

# Static pattern rule for the zip files
$(ZIPS): z_%.zip: z_%
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
	-rm na_tile_list.*
	-rm aus_pacific_tile_list.*
