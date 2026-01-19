; ============================================================================
; START_GCODE pro PrusaSlicer s MMU AD5X - Vícebarevný tisk
; ============================================================================
; Automatické nastavení parametrů slotů podle použitých extruderů v projektu
;
; Dostupné proměnné PrusaSliceru:
; - {is_extruder_used[N]}          : 0 nebo 1 - zda je extruder N použitý
; - {extruder_temperature[N]}      : Teplota extruderu N (°C)
; - {first_layer_temperature[N]}   : Teplota první vrstvy extruderu N
; - {filament_type[N]}             : Typ filamentu (PLA, PETG, FLEX, atd.)
; - {filament_loading_speed[N]}    : Rychlost zavedení filamentu (mm/s) - vlastní vlastnost
; - {filament_unloading_speed[N]}  : Rychlost vytažení filamentu (mm/s) - vlastní vlastnost
; - {bed_temperature}              : Teplota tiskové plochy
;
; DŮLEŽITÉ: filament_loading_speed a filament_unloading_speed jsou v mm/s!
; Přepočítávají se na mm/min vynásobením 60:
; Příklad: 5 mm/s = 5 * 60 = 300 mm/min
;
; Index N: 0 = Slot 1, 1 = Slot 2, 2 = Slot 3, 3 = Slot 4
; ============================================================================

M118 "===== MMU AD5X START_GCODE - MULTI-MATERIAL ====="

; ============================================================================
; DETEKCE A KONFIGURACE SLOTŮ
; ============================================================================

{if is_extruder_used[0]}
M118 "Konfiguruju EXTRUDER 1 - {filament_type[0]}"
SET_EXTRUDER_PARAM EXTRUDER=1 \
  TEMP={temperature[0]} \
  FILAMENT_TYPE="{filament_type[0]}" \
  FILAMENT_LOAD_SPEED={filament_loading_speed[0] * 60 * 60} \
  FILAMENT_UNLOAD_SPEED={filament_unloading_speed[0] * 60} \
  FILAMENT_UNLOAD_AFTER_CUTTING={filament_retract_length_toolchange[0]} \
  FILAMENT_UNLOAD_BEFORE_CUTTING={filament_retract_length_toolchange[0]} \
  FILAMENT_COLOUR={filament_colour[0]} \
  FILAMENT_DROP_LENGTH={filament_minimal_purge_on_wipe_tower[0] / (0.7854 * filament_diameter[0] * filament_diameter[0])}
M118 "EXTRUDER 1: {filament_type[0]} @ {temperature[0]}°C (Load={filament_loading_speed[0] * 60 * 60}mm/min, Unload={filament_unloading_speed[0] * 60}mm/min)"
{endif}

{if is_extruder_used[1]}
M118 "Konfiguruju EXTRUDER 2 - {filament_type[1]}"
SET_EXTRUDER_PARAM EXTRUDER=2 \
  TEMP={temperature[1]} \
  FILAMENT_TYPE="{filament_type[1]}" \
  FILAMENT_LOAD_SPEED={filament_loading_speed[1] * 60 * 60} \
  FILAMENT_UNLOAD_SPEED={filament_unloading_speed[1] * 60} \
  FILAMENT_UNLOAD_AFTER_CUTTING={filament_retract_length_toolchange[1]} \
  FILAMENT_UNLOAD_BEFORE_CUTTING={filament_retract_length_toolchange[1]} \
  FILAMENT_COLOUR={filament_colour[1]} \
  FILAMENT_DROP_LENGTH={filament_minimal_purge_on_wipe_tower[1] / (0.7854 * filament_diameter[1] * filament_diameter[1])}
M118 "EXTRUDER 2: {filament_type[1]} @ {temperature[1]}°C (Load={filament_loading_speed[1] * 60 * 60}mm/min, Unload={filament_unloading_speed[1] * 60}mm/min)"
{endif}

{if is_extruder_used[2]}
M118 "Konfiguruju EXTRUDER 3 - {filament_type[2]}"
SET_EXTRUDER_PARAM EXTRUDER=3 \
  TEMP={temperature[2]} \
  FILAMENT_TYPE="{filament_type[2]}" \
  FILAMENT_LOAD_SPEED={filament_loading_speed[2] * 60 * 60} \
  FILAMENT_UNLOAD_SPEED={filament_unloading_speed[2] * 60} \
  FILAMENT_UNLOAD_AFTER_CUTTING={filament_retract_length_toolchange[2]} \
  FILAMENT_UNLOAD_BEFORE_CUTTING={filament_retract_length_toolchange[2]} \
  FILAMENT_COLOUR={filament_colour[2]} \
  FILAMENT_DROP_LENGTH={filament_minimal_purge_on_wipe_tower[2] / (0.7854 * filament_diameter[2] * filament_diameter[2])}
M118 "EXTRUDER 3: {filament_type[2]} @ {temperature[2]}°C (Load={filament_loading_speed[2] * 60 * 60}mm/min, Unload={filament_unloading_speed[2] * 60}mm/min)"
{endif}

{if is_extruder_used[3]}
M118 "Konfiguruju EXTRUDER 4 - {filament_type[3]}"
SET_EXTRUDER_PARAM EXTRUDER=4 \
  TEMP={temperature[3]} \
  FILAMENT_TYPE="{filament_type[3]}" \
  FILAMENT_LOAD_SPEED={filament_loading_speed[3] * 60 * 60} \
  FILAMENT_UNLOAD_SPEED={filament_unloading_speed[3] * 60} \
  FILAMENT_UNLOAD_AFTER_CUTTING={filament_retract_length_toolchange[3]} \
  FILAMENT_UNLOAD_BEFORE_CUTTING={filament_retract_length_toolchange[3]} \
  FILAMENT_COLOUR={filament_colour[3]} \
  FILAMENT_DROP_LENGTH={filament_minimal_purge_on_wipe_tower[3] / (0.7854 * filament_diameter[3] * filament_diameter[3])}
  FILAMENT_DROP_LENGTH_ADD={filament_minimal_purge_on_wipe_tower[3] / (0.7854 * filament_diameter[3] * filament_diameter[3])}
M118 "EXTRUDER 4: {filament_type[3]} @ {temperature[3]}°C (Load={filament_loading_speed[3] * 60 * 60}mm/min, Unload={filament_unloading_speed[3] * 60}mm/min)"
{endif}

; ============================================================================
; ZAHÁJENÍ TISKU
; ============================================================================

M118 "Zahajuji tiskárnu..."

; Určit počáteční nástroj - první použitý slot
{if is_extruder_used[0]}
START_PRINT INITIAL_TOOL=1 NOZZLE_TEMP={extruder_temperature[0]} BED_TEMP={bed_temperature}
{elsif is_extruder_used[1]}
START_PRINT INITIAL_TOOL=2 NOZZLE_TEMP={extruder_temperature[1]} BED_TEMP={bed_temperature}
{elsif is_extruder_used[2]}
START_PRINT INITIAL_TOOL=3 NOZZLE_TEMP={extruder_temperature[2]} BED_TEMP={bed_temperature}
{elsif is_extruder_used[3]}
START_PRINT INITIAL_TOOL=4 NOZZLE_TEMP={extruder_temperature[3]} BED_TEMP={bed_temperature}
{else}
; Výchozí hodnota, pokud není vybrán žádný extruder
START_PRINT INITIAL_TOOL=1 NOZZLE_TEMP=200 BED_TEMP={bed_temperature}
{endif}

M118 "Příprava tisku HOTOVA - Tisk začíná..."

; ============================================================================
; KONFIGURACE V PRUSASLICERU
; ============================================================================
;
; 1. VLASTNÍ VLASTNOSTI FILAMENTU - VELMI DŮLEŽITÉ!
; ============================================================================
; Abyste mohli v START_GCODE používat filament_loading_speed a 
; filament_unloading_speed, MUSÍTE je přidat do profilu filamentu:
;
; KROKY:
; a) Otevřete PrusaSlicer
; b) Jděte na "Filament Settings"
; c) Vhledejte sekci "Custom Properties" (nebo "Vlastní vlastnosti")
; d) Přidejte nové vlastnosti - DŮLEŽITÉ: zadejte v mm/s (milimetrech za sekundu)!
;
;    filament_loading_speed = 5         # 5 mm/s = 300 mm/min
;    filament_unloading_speed = 10      # 10 mm/s = 600 mm/min
;    filament_fan_speed = 102           # (0-255)
;
; e) Nastavte správné hodnoty pro KAŽDÝ filament v projektu
;
; 2. PŘEPOČTY RYCHLOSTÍ
; ============================================================================
; START_GCODE automaticky přepočítá:
; - 1 mm/s   → 60 mm/min
; - 5 mm/s   → 300 mm/min
; - 10 mm/s  → 600 mm/min
; - 20 mm/s  → 1200 mm/min
;
; Vzorec: mm/min = mm/s * 60
;
; 3. POUŽITÍ V PROJEKTU
; ============================================================================
; Pokud máte v projektu více materiálů:
;
; a) Přidejte více extruderů v Print Settings
; b) Přiřaďte správný filament ke každému extruderu
; c) PrusaSlicer automaticky:
;    - Detekuje které extrudery jsou použité ({is_extruder_used[N]})
;    - Načte hodnoty teploty a typu filamentu
;    - Načte vlastní vlastnosti (filament_loading_speed, atd.)
; d) START_GCODE pak automaticky zavolá SET_SLOT_PARAM pro každý slot
;
; 4. PŘÍKLAD PROJEKTU
; ============================================================================
; Projekt s 2 materiály:
; - Slot 1: PLA (220°C, filament_loading_speed=5, filament_unloading_speed=10)
; - Slot 2: PETG (240°C, filament_loading_speed=4, filament_unloading_speed=8)
;
; START_GCODE AUTOMATICKY SPUSTÍ:
; SET_SLOT_PARAM SLOT=1 TEMP=220 FILAMENT_TYPE="PLA" FILAMENT_LOAD_SPEED=300 FILAMENT_UNLOAD_SPEED=600
; SET_SLOT_PARAM SLOT=2 TEMP=240 FILAMENT_TYPE="PETG" FILAMENT_LOAD_SPEED=240 FILAMENT_UNLOAD_SPEED=480
; START_PRINT INITIAL_TOOL=1 NOZZLE_TEMP=220 BED_TEMP=60
;
; 5. KONTROLA V KLIPPERU
; ============================================================================
; Po spuštění tisku můžete zkontrolovat nastavené parametry:
;
; > SHOW_ALL_SLOT_PARAMS
;
; Zobrazí se:
; ===== KONFIGURACE VŠECH SLOTŮ =====
; Parametry slotu 1:
;   Teplota: 220°C
;   Typ filamentu: PLA
;   Load speed: 300 mm/min
;   Unload speed: 600 mm/min
; atd.
