# Integrace PrusaSlic3ru s AD5X MMU

Kompletní návod na konfiguraci PrusaSlic3ru pro práci s AD5X MMU přes Klipper.

---

## 📋 Přehled

AD5X MMU v Klipperu je nakonfigurován tak, aby přijímal příkazy z PrusaSlic3ru s kompletními parametry pro každý filament (teplota, rychlost zavedení, délka zavedení, atd.).

Místo standardních příkazů `T0-T3` se používá `MMU_CHANGE_TOOL` s parametry, které se předávají přímo ze slic3ru.

---

## 🔧 Konfigurace PrusaSlic3r

### 1. Nastavení Filamentů

V každém profilu filamentu v PrusaSlic3ru musíte nastavit:

#### Fyzické Parametry (záložka "Filament")
- **Teplota trysky:** 210-250°C (dle materiálu)
- **Teplota plochy:** 20-80°C

#### Vlastní Parametry MMU (záložka "Notes")

Přidejte JSON do pole Notes (nebo vytvořte custom field):
```json
{
  "mmu": {
    "insert_len": 90,
    "insert_speed": 1200,
    "remove_len": 90,
    "remove_speed": 1200
  }
}
```

**Alternativně** - přidat do "Filament notes" obyčejný text:
```
MMU: INSERT_LEN=90 INSERT_SPEED=1200 REMOVE_LEN=90 REMOVE_SPEED=1200
```

---

### 2. Custom G-Code v PrusaSlic3ru

#### Změna Nástroje (Tool Change)

V **Print Settings** → **Custom G-code** → **Tool change G-code** přidejte:

```gcode
; Výměna filamentu do nástroje {next_filament_num}
M118 "Výměna na filament {next_filament_num}..."
MMU_CHANGE_TOOL TOOL={next_filament_num} HOTEND_TEMP={next_extruder_temp}
```

**Pokud máte custom parametry v profilu**, použijte komplexnější verzi:

```gcode
; Výměna filamentu do nástroje {next_filament_num}
M118 "Výměna na filament {next_filament_num}..."
; Vyměň filament s parametry dle materiálu
{% if next_filament_num == 0 %}
  MMU_CHANGE_TOOL TOOL=0 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=90 INSERT_SPEED=1200 REMOVE_LEN=90 REMOVE_SPEED=1200
{% elsif next_filament_num == 1 %}
  MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=80 INSERT_SPEED=800 REMOVE_LEN=80 REMOVE_SPEED=800
{% elsif next_filament_num == 2 %}
  MMU_CHANGE_TOOL TOOL=2 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=100 INSERT_SPEED=1000 REMOVE_LEN=100 REMOVE_SPEED=1000
{% elsif next_filament_num == 3 %}
  MMU_CHANGE_TOOL TOOL=3 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=95 INSERT_SPEED=900 REMOVE_LEN=95 REMOVE_SPEED=900
{% endif %}
```

---

#### Start Print (Inicializace)

V **Print Settings** → **Custom G-code** → **Start G-code** přidejte:

```gcode
; Inicializace tiskárny
M104 S0  ; Vypnout trysku (pokud byla teplá)
M140 S0  ; Vypnout plochu
G28      ; Domů

; Příprava MMU s prvním filamentem
START_PRINT INITIAL_TOOL={first_filament_num} NOZZLE_TEMP={first_layer_temperature} BED_TEMP={first_layer_bed_temperature}

; Vaše další start příkazy...
G29      ; BL-touch kalibrování (pokud máte)
```

---

#### End Print

V **Print Settings** → **Custom G-code** → **End G-code** přidejte:

```gcode
; Konec tisku
M104 S0  ; Vypnout trysku
M140 S0  ; Vypnout plochu
G28 X Y  ; Domů X,Y
G1 Z{max_print_height} F3000  ; Vzít hlavu

; Parkování pro levý horní roh (bez obsahu):
G1 X0 Y0 F3000

M118 "Tisk hotov!"
```

---

## 📊 Příklady Parametrů dle Materiálu

### PLA (Standard)
```gcode
INSERT_LEN=90 INSERT_SPEED=1200 REMOVE_LEN=90 REMOVE_SPEED=1200
```

### PETG
```gcode
INSERT_LEN=100 INSERT_SPEED=1000 REMOVE_LEN=100 REMOVE_SPEED=1000
```

### TPU/Flexible
```gcode
INSERT_LEN=80 INSERT_SPEED=800 REMOVE_LEN=80 REMOVE_SPEED=800
```

### ABS
```gcode
INSERT_LEN=110 INSERT_SPEED=900 REMOVE_LEN=110 REMOVE_SPEED=900
```

### Silk/Premium
```gcode
INSERT_LEN=95 INSERT_SPEED=1000 REMOVE_LEN=95 REMOVE_SPEED=900
```

---

## 🎯 Krok za Krokem - Prvotní Nastavení

### 1. Vytvořit Profil pro Každý Filament

V PrusaSlic3r:
1. **Filament** → **+** → Nový profil
2. Pojmenovat dle materiálu (např. "PLA-Red", "PETG-Blue")
3. Nastavit teplotu trysky a plochy
4. V **Notes** přidat MMU parametry:
   ```
   PLA - standard MMU setup
   ```

### 2. Konfigurovat Print Profile

1. **Print Settings** → váš profil
2. Jít na **Custom G-code**
3. Do pole **Tool change G-code** vložit:
   ```gcode
   ; Výměna filamentu
   MMU_CHANGE_TOOL TOOL={next_filament_num} HOTEND_TEMP={next_extruder_temp}
   ```
4. Do pole **Start G-code** vložit:
   ```gcode
   START_PRINT INITIAL_TOOL={first_filament_num} NOZZLE_TEMP={first_layer_temperature} BED_TEMP={first_layer_bed_temperature}
   ```

### 3. Vyzkoušet

1. Otevřít multi-color model v PrusaSlic3ru
2. Přiřadit filamenty (kliknutí na barvy na modelu)
3. Slice
4. Otevřít Preview
5. Kontrola G-code (v Preview vidíte změny nástrojů)

---

## 🔍 Kontrola Vygenerovaného G-Code

V **G-code Preview** (Preview tab):
1. Pohybem po průběhu vidíte změny nástrojů
2. Kliknutím na vrstvu vidíte obsah G-code
3. Hledejte řádky jako:
   ```
   ; Výměna filamentu
   MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220
   ```

---

## ⚡ Optimalizace pro Vaši Tiskárnu

### Nastavení Pozice Nástrojů

Pokud máte speciální pozici pro výměnu filamentu (např. mimo tiskový prostor), přidejte ji do Start G-code:

```gcode
; Park na pozici změny nástrojů
G1 X-5 Y-5 Z50 F3000  ; Volné místo mimo tisk

; Pak pokračuj s START_PRINT...
START_PRINT INITIAL_TOOL={first_filament_num} ...
```

### Testy Pred Tiskem

```gcode
; Test zavedení filamentu 0
T0

; Test zavedení filamentu 1
T1

; Test zavedení filamentu 2
T2

; Test zavedení filamentu 3
T3
```

**Poznámka:** T0-T3 jsou rezervovány (placeholder), používejte pro manuální test:
```gcode
MMU_CHANGE_TOOL TOOL=0
MMU_CHANGE_TOOL TOOL=1
```

---

## 🚨 Řešení Problémů

### Problém: Filament se nezavádí

**Řešení:**
1. Zkontrolujte `INSERT_LEN` - je dost vysoká?
2. Zkuste zvýšit `INSERT_SPEED` o 100mm/min
3. Spusťte test:
   ```gcode
   _MMU_INSERT_FILAMENT SLOT=0 LEN=100 SPEED=1000
   ```

### Problém: Filament se neodebírá

**Řešení:**
1. Zvýšit `REMOVE_SPEED`
2. Zvýšit `REMOVE_LEN`
3. Test:
   ```gcode
   _MMU_REMOVE_FILAMENT SLOT=0 LEN=100 SPEED=1200
   ```

### Problém: Špatná teplota

**Řešení:**
1. V PrusaSlic3ru zkontrolujte teplotu u každého filamentu
2. Teplota se bere ze specifikace filamentu
3. Custom přepsání v G-code:
   ```gcode
   MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=225  ; Vyšší teplota
   ```

---

## 📝 Checklist Pro Prvotní Spuštění

- [ ] MMU konektor připojen v Klipperu
- [ ] Senzory nakonfigurovány (viz SENSOR_CONFIGURATION.md)
- [ ] `mmu_ad5x.cfg` je zahrnut v printer.cfg
- [ ] PrusaSlic3r nainstalován a aktualizován
- [ ] Print profile vytvořen se Start/Tool change G-code
- [ ] Filament profily vytvořeny se správnými teplotami
- [ ] Test: spusťte `MMU_STATUS` v Klipperu
- [ ] Test: jednoduché single-color tisky fungují
- [ ] Test: multi-color tisk bez skutečného tisku (jen preview)
- [ ] Test: malý multi-color tisk (max 3 barvy)

---

## 📚 Dodatečné Zdroje

- Viz [IFS_COMMANDS.md](IFS_COMMANDS.md) pro reference všech příkazů
- Viz [SENSOR_CONFIGURATION.md](SENSOR_CONFIGURATION.md) pro nastavení senzorů
- Viz [mmu_ad5x.cfg](mmu_ad5x.cfg) pro zdrojový kód maker

---

## 🔗 Příklad Kompletního Custom G-Code

### Start G-code (zkopírujte do PrusaSlic3r)
```gcode
; ============ START PRINT ============
G28                 ; Home
M104 S0             ; Reset teplota
M140 S0             ; Reset plocha

; Inicializace MMU
START_PRINT INITIAL_TOOL={first_filament_num} NOZZLE_TEMP={first_layer_temperature} BED_TEMP={first_layer_bed_temperature}

; Kalibrování (pokud máte BL-touch)
; G29

; ============ PŘIPRAVENO NA TISK ============
```

### Tool Change G-code (zkopírujte do PrusaSlic3r)
```gcode
; ============ VÝMĚNA FILAMENTU ============
; Výměna na filament {next_filament_num}
M118 "Výměna na filament {next_filament_num}..."

; Sjezdit dolů pokud je potřeba
G1 Z{current_z + 2} F3000

; Výměna filamentu s teplotou dle materiálu
MMU_CHANGE_TOOL TOOL={next_filament_num} HOTEND_TEMP={next_extruder_temp}

; Vrátit se zpět
G1 Z{current_z} F3000

M118 "Výměna hotova"
; ============ POKRAČOVÁNÍ V TISKU ============
```

### End G-code (zkopírujte do PrusaSlic3r)
```gcode
; ============ KONEC TISKU ============
M104 S0             ; Vypnout trysku
M140 S0             ; Vypnout plochu
G28 X Y             ; Home XY (bez Z)

; Parkování
G1 X0 Y0 F3000
G1 Z{max_print_height} F3000

M118 "Tisk hotov!"
; ============ HOTOVO ============
```

---

Poslední aktualizace: 16.1.2026
