#AUS_PAC=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell cat aus_pacific_tile_list) ) )
AUS_PAC=$(addprefix Ortho4XP/Tiles/zOrtho4XP_, $(basename $(shell head -n 20 aus_pacific_tile_list) ) )

all:
	echo ""

ortho4xp.diff:
	cd Ortho4XP && git diff > ../ortho4xp.diff

Ortho4XP:
	git clone --depth=1 https://github.com/oscarpilote/Ortho4XP.git
	cd Ortho4XP && patch -p1 -u < ../ortho4xp.diff

Ortho4XP/Tiles/zOrtho4XP_%: Ortho4XP
	@echo "Make tile $@" 
	set -e;\
	export COORDS=$$(echo $@ | sed -e 's/.*_\([-+][0-9]\+\)\([-+][0-9]\+\)/\1 \2/g');\
 	cd $< && python3 Ortho4XP_v130.py $$COORDS BI 16
	

z_aus_pac:
	mkdir $@

z_aus_pac.zip: z_aus_pac $(AUS_PAC) 
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/'Earth nav data' $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/terrain $</.
	cp -r Ortho4XP/Tiles/zOrtho4XP_*/textures $</.
	cp -r Ortho4XP/yOrtho4XP_Overlays $</.
	cp ORTHO_SETUP.md $</.
	zip -s 1G -r $< $<

clean:
	-rm -rf Ortho4XP/Tiles
	-rm -rf Ortho4XP/yOrtho4XP_Overlays
