#!/usr/bin/env python3

import os
import sys
Ortho4XP_dir='..' if getattr(sys,'frozen',False) else '.'
sys.path.append(os.path.join(Ortho4XP_dir,'src'))
import O4_Overlay_Utils as OVLY
import O4_Config_Utils as CFG  # CFG imported last because it can modify other modules variables

if __name__ == '__main__':
    lat=int(sys.argv[1])
    lon=int(sys.argv[2])
    tile=CFG.Tile(lat,lon,'')
    OVLY.build_overlay(lat, lon)
