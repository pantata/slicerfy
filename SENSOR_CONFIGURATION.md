# Konfigurace CUSTOM ZMOD IFS senzorů pro AD5X MMU

## Přehled

Konfigurace AD5X MMU pracuje s **CUSTOM senzory ze zmod IFS projektu**, nikoliv se standardními Klipper sensory!

Tyto senzory jsou v Pythonu a integrují se přímo s IFS řídící jednotkou.

---

## 1. Senzory - Jaké jsou potřeba

### 1.1 Head Switch Sensor (`head_switch_sensor`)
- **Účel**: Detekce přítomnosti filamentu v hlavi (extruderu)
- **Typ**: `zmod_ifs_switch_sensor` (CUSTOM!)
- **Důležité**: Musí se jmenovat **PŘESNĚ** `head_switch_sensor`
- **Zapojení**: Detekuje kdy konči filament - vyvolá `runout_gcode`

### 1.2 IFS Motion Sensory (1-4)
- **Účel**: Detekce pohybu filamentu v jednotlivých portech IFS
- **Typ**: `zmod_ifs_motion_sensor` (CUSTOM!)
- **Názvy MUSÍ BÝT**: `_ifs_motion_sensor_1`, `_ifs_motion_sensor_2`, `_ifs_motion_sensor_3`, `_ifs_motion_sensor_4`
- **Konfigurace**: `port: 1-4` mapuje na fyzické porty IFS
- **Citlivost**: Interní v zmod modulu (detection_length ~10mm)

### 1.3 IFS Port Switch Sensory (1-4)
- **Účel**: Detekce přítomnosti filamentu v jednotlivých portech
- **Typ**: `zmod_ifs_switch_sensor` s `type: port`
- **Názvy MUSÍ BÝT**: `_ifs_port_sensor_1`, `_ifs_port_sensor_2`, `_ifs_port_sensor_3`, `_ifs_port_sensor_4`
- **Konfigurace**: `type: port` + `port: 1-4`
- **Funkce**: Detekuje vložení a konec filamentu v jednotlivých portech

---

## 2. Doporučená konfigurace senzorů

Vložte do vašeho `printer.cfg`:

```klipper
################################################################################
# SENZORY PRO AD5X MMU - CUSTOM ZMOD IFS MODULY
################################################################################

# Head switch sensor - detekce filamentu v hlavi (extruderu)
[zmod_ifs_switch_sensor head_switch_sensor]
pause_on_runout: False
runout_gcode:
    _MMU_RUNOUT_HEAD

# IFS Motion sensory - detekce pohybu v jednotlivych portech
[zmod_ifs_motion_sensor _ifs_motion_sensor_1]
pause_on_runout: False
port: 1

[zmod_ifs_motion_sensor _ifs_motion_sensor_2]
pause_on_runout: False
port: 2

[zmod_ifs_motion_sensor _ifs_motion_sensor_3]
pause_on_runout: False
port: 3

[zmod_ifs_motion_sensor _ifs_motion_sensor_4]
pause_on_runout: False
port: 4

# IFS Port switch sensory - detekce prisutnosti filamentu v portech
[zmod_ifs_switch_sensor _ifs_port_sensor_1]
pause_on_runout: False
type: port
port: 1
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=0
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=0

[zmod_ifs_switch_sensor _ifs_port_sensor_2]
pause_on_runout: False
type: port
port: 2
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=1
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=1

[zmod_ifs_switch_sensor _ifs_port_sensor_3]
pause_on_runout: False
type: port
port: 3
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=2
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=2

[zmod_ifs_switch_sensor _ifs_port_sensor_4]
pause_on_runout: False
type: port
port: 4
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=3
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=3
```

**POZOR**: 
- `port` v senzoru je 1-4 (fyzické porty IFS)
- `SLOT` v makru je 0-3 (virtuální sloty v G-kodu)
- Mapování: port 1 = slot 0, port 2 = slot 1, atd.

---

## 3. Jak senzory ovlivňují chování

### 3.1 Výměna filamentu (T0-T3, MMU_CHANGE_TOOL)

```
┌──────────────────────────────────────────────────┐
│ 1. UNLOAD (Vytažení)                             │
│   - Retrakt -20mm                                │
│   - Snížení teploty o 30°C                       │
│   - Řezání na páku                               │
│   - IFS vytažení filamentu                       │
│   - ✓ SENZOR: head_switch_sensor MUSÍ hlásit    │
│     ABSENCI (nebo se vyvolá chyba)               │
└──────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────┐
│ 2. SELECT (Výběr)                                │
│   - IFS zavedení filamentu z nového portu        │
└──────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────┐
│ 3. LOAD (Zavedení)                               │
│   - M104 zahřívání (bez čekání)                  │
│   - IFS čistění do hlavi (PURGE)                 │
│   - M109 čekání na teplotu                       │
│   - Značení jako zavědeného (IFS)                │
│   - Kontrola pohybu                              │
│   - ✓ SENZOR: head_switch_sensor MUSÍ hlásit    │
│     PŘÍTOMNOST (nebo se vyvolá chyba)            │
└──────────────────────────────────────────────────┘
```

### 3.2 Během tisku - Detekce runoutu

#### Když skončí filament v hlavi:
```
1. head_switch_sensor detekuje runout (absence)
2. Automaticky se zavolá: _MMU_RUNOUT_HEAD
3. Makro kontroluje: je ještě filament v IFS portu?
   ✓ ANO → Pokus se pokračovat (měkký retrakt + znovu zapnout senzor)
   ✗ NE  → PAUSE s důvodem "runout_no_backup"
```

#### Když skončí filament v IFS (motion sensor):
```
1. _ifs_motion_sensor_X detekuje runout
2. Makro zkoušel: je filament v hlavi?
   ✓ ANO → _MMU_CONSUME_FILAMENT (pumping loop s čistěním)
   ✗ NE  → PAUSE pro výměnu
```

#### Když skončí filament v konkrétním portu:
```
1. _ifs_port_sensor_X detekuje runout
2. Automaticky se zavolá: _MMU_RUNOUT_SLOT SLOT=X
3. Pokud je port aktivní: pokus čistit zbýtek
4. Pokud není aktivní: ignoruje se
```

### 3.3 Při vložení filamentu do portu:
```
1. _ifs_port_sensor_X detekuje vložení (insert)
2. Automaticky se zavolá: _MMU_INSERT_DETECTED SLOT=X
3. Makro loguje vložení
   (Běžně se používá v mmu_colors dialogu)
```

---

## 4. Mapování Port ↔ Slot

| Fyzický Port IFS | Virtuální Slot G-kodu | Senzory |
|---|---|---|
| 1 | 0 | `_ifs_motion_sensor_1`, `_ifs_port_sensor_1` |
| 2 | 1 | `_ifs_motion_sensor_2`, `_ifs_port_sensor_2` |
| 3 | 2 | `_ifs_motion_sensor_3`, `_ifs_port_sensor_3` |
| 4 | 3 | `_ifs_motion_sensor_4`, `_ifs_port_sensor_4` |

**Příklad**: Když zvolíte `T0`, pracuje s portem 1 a `_ifs_motion_sensor_1`

---

## 5. Chytrá detekce filamentu v hlavi (START_PRINT)

Při spuštění tisku můžete povolit automatickou detekci, která určí, ze kterého portu je filament:

```klipper
[gcode_macro START_PRINT]
params:
  INITIAL_TOOL: 0
  NOZZLE_TEMP: 200
  BED_TEMP: 60
gcode:
    # ... běžný setup ...
    
    # OPCIONÁLNĚ: Detekuj filament v hlavi
    _MMU_DETECT_FILAMENT_IN_HEAD
    
    # Pak zavedení...
```

### Jak detekce funguje:
1. Zjistí, zda je vůbec nějaký filament v hlavi senzorem
2. Pokud ano, provede malý pohyb (E5mm dopředu/zpět)
3. Sleduje, který motion sensor (_ifs_motion_sensor_1-4) hlásí pohyb
4. Automaticky nastaví `mmu_current_tool` na detekovaný port

---

## 6. Bezpečnostní ověření

Po zavedení/vyjmutí filamentu se automaticky ověří:

```klipper
_MMU_VERIFY_LOAD      # Ověř že filament je v hlavi (head_switch_sensor)
_MMU_VERIFY_UNLOAD    # Ověř že filament je pryč (head_switch_sensor)
```

Pokud ověření selže:
- ❌ Zavedení: `action_raise_error()` - tisk se zastaví s chybou
- ❌ Vyjmutí: `action_raise_error()` - tisk se zastaví s chybou

---

## 7. Čištění zbývajícího filamentu (POOP)

Když skončí filament v IFS ale v hlavi je ještě něco:

```klipper
_MMU_CONSUME_FILAMENT [ITERATIONS=10] [LENGTH=10] [SPEED=100]
```

Spustí se **pumping loop**:
- Každá iterace: `E+{LENGTH} F{SPEED}` (dopředu) → pauza → `E-{LENGTH}` (zpět)
- Senzor se kontroluje v každé iteraci
- Smyčka se zastaví když:
  - head_switch_sensor hlásí absenci filamentu (je vytlačený)
  - NEBO projdou všechny iterace

---

## 8. Ladění a testování

### Test: Kontrola stavu senzorů
```gcode
; V Klipper Web UI do konzole:
QUERY_FILAMENT_SENSOR SENSOR=head_switch_sensor
QUERY_FILAMENT_SENSOR SENSOR=_ifs_motion_sensor_1
QUERY_FILAMENT_SENSOR SENSOR=_ifs_port_sensor_1
; atd...
```

### Test: Vypnutí senzoru na čas
```gcode
SET_FILAMENT_SENSOR SENSOR=head_switch_sensor ENABLE=0  ; vypnout
SET_FILAMENT_SENSOR SENSOR=head_switch_sensor ENABLE=1  ; zapnout
```

### Test: Manuální spuštění makra
```gcode
_MMU_DETECT_FILAMENT_IN_HEAD              ; detekce v hlavi
_MMU_VERIFY_LOAD                          ; test zavedení
_MMU_VERIFY_UNLOAD                        ; test vyjmutí
_MMU_CONSUME_FILAMENT ITERATIONS=3        ; test čištění
```

---

## 9. Příklad úplné konfigurace v printer.cfg

```klipper
# Přidejte na konec printer.cfg:

[zmod_ifs]
debug: False

[zmod_ifs_switch_sensor head_switch_sensor]
pause_on_runout: False
runout_gcode:
    _MMU_RUNOUT_HEAD

[zmod_ifs_motion_sensor _ifs_motion_sensor_1]
pause_on_runout: False
port: 1

[zmod_ifs_motion_sensor _ifs_motion_sensor_2]
pause_on_runout: False
port: 2

[zmod_ifs_motion_sensor _ifs_motion_sensor_3]
pause_on_runout: False
port: 3

[zmod_ifs_motion_sensor _ifs_motion_sensor_4]
pause_on_runout: False
port: 4

[zmod_ifs_switch_sensor _ifs_port_sensor_1]
pause_on_runout: False
type: port
port: 1
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=0
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=0

[zmod_ifs_switch_sensor _ifs_port_sensor_2]
pause_on_runout: False
type: port
port: 2
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=1
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=1

[zmod_ifs_switch_sensor _ifs_port_sensor_3]
pause_on_runout: False
type: port
port: 3
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=2
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=2

[zmod_ifs_switch_sensor _ifs_port_sensor_4]
pause_on_runout: False
type: port
port: 4
runout_gcode:
    _MMU_RUNOUT_SLOT SLOT=3
insert_gcode:
    _MMU_INSERT_DETECTED SLOT=3

# Zahrňte MMU konfiguraci:
[include mmu_ad5x.cfg]
```

---

## 10. Souhrn - Automatické akce

| Situace | Senzor | Volá se makro |
|---------|--------|---|
| START_PRINT | head_switch_sensor | Detekce (optional) |
| T0-T3 UNLOAD | head_switch_sensor | _MMU_VERIFY_UNLOAD |
| T0-T3 LOAD | head_switch_sensor | _MMU_VERIFY_LOAD |
| Tisk - runout hlava | head_switch_sensor | _MMU_RUNOUT_HEAD |
| Tisk - runout IFS | _ifs_motion_sensor_X | _MMU_RUNOUT_MOTION |
| Vložení do portu | _ifs_port_sensor_X | _MMU_INSERT_DETECTED |

---

## 11. Otázky a odpovědi

**Q: Co je `pause_on_runout: False`?**
A: Říká senzoru aby se nespouštěl automatický PAUSE. Místo toho zavolá naš `runout_gcode` makro, kde máme vlastní logiku.

**Q: Proč jsou port a slot různé?**
A: `port` je fyzické číslo v IFS (1-4). `SLOT` je virtuální číslo v G-kodu (0-3) pro kompatibilitu s ostatními MMU kódy.

**Q: Co když sensory nejsou nainstalované?**
A: Makra budou fungovat, ale bez ověření bezpečnosti. Budou jen logovat "UPOZORNĚNÍ: senzor není nakonfigurován".

**Q: Mohu mít jen head_switch_sensor bez port_sensorů?**
A: Ano, ale pak nebudete mít detekci konce filamentu v jednotlivých portech.

**Q: Co dělá `type: port`?**
A: Říká senzoru, že sleduje konkrétní port IFS (nikoli hlavu). Bez tohoto by se choval jako head sensor.


