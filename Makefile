SPLITSIZE?=150

AUS_PACS:=$(addprefix z_aus_pac_, $(shell ls aus_pac_tile_list.* | awk -F. '{ print $$2 }') ) 
AUS_PAC_ZIPS=$(addsuffix .zip, $(AUS_PACS))

NAS:=$(addprefix z_na_, $(shell ls na_tile_list.* | awk -F. '{ print $$2 }') ) 
NA_ZIPS=$(addsuffix .zip, $(NAS))

EURS:=$(addprefix z_eur_, $(shell ls eur_tile_list.* | awk -F. '{ print $$2 }') ) 
EUR_ZIPS=$(addsuffix .zip, $(EURS))

TESTS:=$(addprefix z_test_, $(shell ls test_tile_list.* | awk -F. '{ print $$2 }') ) 
TEST_ZIPS=$(addsuffix .zip, $(TESTS))


ZIPS=$(AUS_PAC_ZIPS) $(NA_ZIPS) $(EUR_ZIPS) $(TEST_ZIPS)

# Get the tiles listed in each list file
.SECONDEXPANSION:
AUS_PAC_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pac_tile_list.$* ) ) )
NA_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat na_tile_list.$* ) ) )
EUR_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat eur_tile_list.$* ) ) )
TEST_TILES = $(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat test_tile_list.$* ) ) )

z_aus_pac_%: aus_pac_tile_list.% $${AUS_PAC_TILES}
	echo "Going to do some $@"

z_na_%: na_tile_list.% $${NA_TILES}
	echo "Going to do some $@"

z_eur_%: eur_tile_list.% $${EUR_TILES}
	echo "Going to do some $@"

z_test_%: test_tile_list.% $${TEST_TILES}
	echo "Going to do some $@"


#allzips: $(AUS_PAC_ZIPS) $(NA_ZIPS)
	
#
# Ortho4XP setup
#

ortho4xp.diff: Ortho4XP
	cd Ortho4XP && git diff > ../ortho4xp.diff

Ortho4XP:
	git clone --depth=1 https://github.com/oscarpilote/Ortho4XP.git
	cd $@ && patch -p1 -u < ../ortho4xp.diff
	cp extract_overlay.py $@/.
	cp Ortho4XP.cfg $@/.
	mkdir $@/tmp


%_chunks: %
	split $< -d -l $(SPLITSIZE) $<.

#
# Tile pack setup
#

Ortho4XP/Tiles/zOrtho4XP_%: Ortho4XP
	@echo "Setup per tile config, if possible"
	mkdir -p $@
	-cp Ortho4XP_$*.cfg $@/.
	@echo "Make tile $@" 
	set -e;\
	export COORDS=$$(echo $* | sed -e 's/\([-+][0-9]\+\)\([-+][0-9]\+\)/\1 \2/g');\
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
	-rm -rf Ortho4XP
	-rm -rf Ortho4XP/Tiles
	-rm *.zip
	-rm -rf z_aus_pac
	-rm na_tile_list.*
	-rm aus_pac_tile_list.*
