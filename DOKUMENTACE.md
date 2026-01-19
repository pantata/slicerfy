# Dokumentace AD5X MMU s IFS

Kompletní dokumentace pro multi-materialový systém AD5X s IFS kontrolérem v Klipperu.

## 📋 Přehled Souborů

### 1. **mmu_ad5x.cfg** - Hlavní Konfigurační Soubor
Kompletní Klipper konfigurace pro AD5X MMU s:
- Inicializace a proměnné (_MMU_VARS, _MMU_INIT_VARIABLES)
- Sensory konfigurace (ZMOD IFS moduly)
- Wrapper makra pro IFS příkazy
- Správa nástrojů (T0-T3)
- Centrální makro pro výměnu filamentu (MMU_CHANGE_TOOL)
- START_PRINT s inicializací MMU
- Obsluha runoutu a senzorů
- Diagnostika a údržba

**Velikost:** ~1200 řádků  
**Použití:** Vložit do `printer.cfg` nebo importovat přes `[include]`

---

### 2. **IFS_COMMANDS.md** - Dokumentace IFS Příkazů
Kompletní referenční příručka všech IFS příkazů:

#### Základní Příkazy:
- **IFS_F10** - Zavedení filamentu (Insert)
- **IFS_F11** - Vytažení filamentu (Remove)
- **IFS_F23** - Označit filament (Mark Inserted)
- **IFS_F24** - Upnout filament (Clamp)
- **IFS_F39** - Uvolnit filament (Release/Purge)
- **IFS_F15** - Reset řídící jednotky
- **IFS_F18** - Uvolnit všechny filamenty
- **IFS_F112** - Zastavit pohyb filamentu
- **IFS_F13** - Zjistit stav IFS

#### Wrapper Makra:
- `_MMU_INSERT_FILAMENT` → IFS_F10
- `_MMU_REMOVE_FILAMENT` → IFS_F11
- `_MMU_MARK_INSERTED` → IFS_F23
- `_MMU_FILAMENT_CLAMP` → IFS_F24
- `_MMU_FILAMENT_PURGE` → IFS_F39
- `_MMU_DRIVER_RESET` → IFS_F15
- `_MMU_PURGE_ALL` → IFS_F18
- `_MMU_STOP_FEED` → IFS_F112
- `_MMU_GET_STATUS` → IFS_F13

**Bonus:** Parametry pro všechna makra, příklady, diagnostika

---

### 3. [PRUSASLICER_INTEGRATION.md](PRUSASLICER_INTEGRATION.md) - Integrace s PrusaSlic3rem
Kompletní návod na konfiguraci PrusaSlic3ru:
- Nastavení filamentů s MMU parametry
- Custom G-code pro Start/Tool Change/End
- Příklady parametrů dle materiálu
- Checklist pro prvotní spuštění
- Troubleshooting guide

---

### 4. **SENSOR_CONFIGURATION.md** - Konfigurace Senzorů
Detailní popis konfigurace ZMOD IFS senzorů:
- Senzor v hlavi (head_switch_sensor)
- Motion sensory v portech (_ifs_motion_sensor_1-4)
- Switch sensory v portech (_ifs_port_sensor_1-4)
- Mapování port ↔ slot
- Příklady konfigurace do printer.cfg

---

### 5. **IMPLEMENTATION_SUMMARY.md** - Souhrn Implementace
Přehled implementace MMU:
- Architektura makra
- Tok výměny filamentu
- Bezpečnostní funkce
- Obsluha chyb
- Příklady použití

---

## 🚀 Rychlý Start

### 1. Instalace
```bash
# Kopíruj mmu_ad5x.cfg do ~/klipper_config/
cp mmu_ad5x.cfg ~/klipper_config/

# Přidej do printer.cfg:
[include mmu_ad5x.cfg]
```

### 2. Konfigurace Senzorů
Viz [SENSOR_CONFIGURATION.md](SENSOR_CONFIGURATION.md) - vložit do printer.cfg:
```klipper
[zmod_ifs_switch_sensor head_switch_sensor]
pause_on_runout: False
runout_gcode: _MMU_RUNOUT_HEAD

[zmod_ifs_motion_sensor _ifs_motion_sensor_1]
pause_on_runout: False
port: 1

# ... atd pro porty 2-4
```

### 3. Základní Příkazy
```gcode
; Inicializace
START_PRINT INITIAL_TOOL=0 NOZZLE_TEMP=220 BED_TEMP=70

; Výměna filamentu (volá se z PrusaSlic3r custom G-code)
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220 INSERT_LEN=100 INSERT_SPEED=1200

; Manuální výměna bez parametrů
MMU_CHANGE_TOOL TOOL=1

; Status
MMU_STATUS
```

---

## 📖 Detailní Dokumentace

### Struktura Makra
```
mmu_ad5x.cfg
├── 1. Inicializace (proměnné, senzory)
├── 2. Wrapper makra (IFS příkazy)
├── 3. Správa nástrojů (T0-T3)
├── 4. MMU_CHANGE_TOOL (čtyři fáze)
├── 5. START_PRINT
├── 6. Diagnostika
├── 7. Pomocná makra
├── 8. Obsluha senzorů
└── 9. Dokumentace
```

### Fáze Výměny Filamentu
1. **UNLOAD** - Retrakce, řezání, vytažení ze IFS
2. **SELECT** - Výběr nového slotu
3. **LOAD** - Zavedení do extruderu, zahřívání
4. **VERIFY** - Ověření a uložení stavu

### Port vs Slot
| Fyzický Port | Virtuální Slot | Příkaz |
|--------------|---|---------|
| 1 | 0 | T0 |
| 2 | 1 | T1 |
| 3 | 2 | T2 |
| 4 | 3 | T3 |

---

## ⚙️ Konfigurace Parametrů

### IFS_F10 (Zavedení)
```gcode
_MMU_INSERT_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0 SLEEP=0

; Parametry:
; SLOT: 0-3 (virtuální slot)
; LEN: 10-500 (mm)
; SPEED: 100-2000 (mm/min)
; WAIT: 0-1 (čekat)
; CHECK: 0-1 (kontrola)
; SLEEP: 0-1 (jen čekání)
```

### IFS_F11 (Vytažení)
```gcode
_MMU_REMOVE_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0

; Parametry:
; SLOT: 0-3
; LEN: 10-500 (mm)
; SPEED: 100-2000 (mm/min)
; WAIT: 0-1
; CHECK: 0-1
```

### Ostatní Makra
Viz [IFS_COMMANDS.md](IFS_COMMANDS.md) pro kompletní parametry

---

## 🔧 Příklady Pokročilé Konfigurace

### Custom Parametry pro Materiály
```gcode
; PLA - standardní
_MMU_INSERT_FILAMENT SLOT=0 LEN=90 SPEED=1200

; TPU - pomalejší, delší
_MMU_INSERT_FILAMENT SLOT=1 LEN=80 SPEED=800

; Silk - jemný
_MMU_INSERT_FILAMENT SLOT=2 LEN=95 SPEED=1000

; Kontrola hlavi
_MMU_INSERT_FILAMENT SLOT=3 LEN=90 CHECK=1
```

### Asynchronní Operace
```gcode
; Bez čekání
_MMU_INSERT_FILAMENT SLOT=0 WAIT=0
_MMU_REMOVE_FILAMENT SLOT=0 WAIT=0

; Paralelní práce
M109 S220  ; Zatímco se čeká, zavedeme filament
```

---

## 🐛 Diagnostika a Ladění

### Zjistit Stav
```gcode
MMU_STATUS      ; Aktuální stav
_MMU_GET_STATUS ; Detailní stav IFS
```

### Reset po Chybě
```gcode
_MMU_STOP_FEED        ; Zastavit pohyb
_MMU_DRIVER_RESET     ; Reset jednotky
_MMU_GET_STATUS       ; Zjistit stav
```

### Manuální Test
```gcode
; Test zavedení
IFS_F10 PRUTOK=1 LEN=50 SPEED=600 WAIT=1

; Test vytažení
IFS_F11 PRUTOK=1 LEN=50 SPEED=600 WAIT=1

; Test stavu
IFS_F13
```

---

## ⚠️ Bezpečnost a Doporučení

### Kritické Poznámky
- **Vždy** nastavte správné číslo slotu/portu (0-3 vs 1-4)
- **Kontrolujte** parametry LEN a SPEED pro nové materiály
- **Testujte** komplexní makra bez tisku
- **Zálohujte** si mmu_variables.cfg před pokusům

### Běžné Chyby
| Chyba | Příčina | Řešení |
|-------|---------|--------|
| Filament nejde dál | Zaseknutí | IFS_F112, IFS_F15 |
| Nesprávný slot | Chybné mapování | Kontrola port vs slot |
| Timeout | Pomalá operace | Zvýšit timeout, snížit SPEED |
| Sensor nereaguje | Nekonfigurován | Viz SENSOR_CONFIGURATION.md |

---

## 📝 Souhrn Dostupných Příkazů

### Základní (Uživatelské)
- `T0`, `T1`, `T2`, `T3` - Výběr filamentu
- `START_PRINT` - Inicializace tisku
- `MMU_CHANGE_TOOL` - Výměna filamentu
- `MMU_STATUS` - Zobrazení stavu

### Pokročilé (Diagnostika)
- `MMU_ENABLE` / `MMU_DISABLE` - Povolení/zákaz MMU
- `MMU_RESET` - Reset stavu
- `MMU_EMERGENCY_STOP` - Nouzové zastavení
- `MMU_PURGE_FILAMENT` - Čistění IFS

### IFS Přímé (Expert)
- `IFS_F10` - Zavedení
- `IFS_F11` - Vytažení
- `IFS_F23` - Označit
- `IFS_F24` - Upnout
- `IFS_F39` - Uvolnit
- `IFS_F15` - Reset
- `IFS_F18` - Čistit všechny
- `IFS_F112` - Stop
- `IFS_F13` - Status

---

## 📚 Další Materiály

- [IFS_COMMANDS.md](IFS_COMMANDS.md) - Kompletní reference IFS příkazů
- [SENSOR_CONFIGURATION.md](SENSOR_CONFIGURATION.md) - Konfigurace senzorů
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Detaily implementace
- [mmu_ad5x.cfg](mmu_ad5x.cfg) - Zdrojový kód

---

## ❓ Nejčastější Otázky

**Q: Jak změnit parametry pro svůj filament?**  
A: Viz [IFS_COMMANDS.md](IFS_COMMANDS.md) - upravte LEN a SPEED podle materiálu.

**Q: Kde je uložen stav MMU?**  
A: V `~/klipper_config/mmu_variables.cfg` - přetrvává restart.

**Q: Mohu spustit MMU bez senzorů?**  
A: Ano, ale bez ověření bezpečnosti (CHECK=0, bez senzorů v config).

**Q: Jak resetovat IFS jednotku?**  
A: `_MMU_DRIVER_RESET` nebo `IFS_F15`

**Q: Jaký je maximální počet slotů?**  
A: 4 (AD5X) - slot 0-3 (port 1-4)

---

## 📞 Podpora

V případě problémů:
1. Zkontrolujte [SENSOR_CONFIGURATION.md](SENSOR_CONFIGURATION.md)
2. Spusťte `MMU_STATUS` a `IFS_F13`
3. Zkuste `IFS_F112` a `IFS_F15`
4. Přečtěte si relevantní sekci v [IFS_COMMANDS.md](IFS_COMMANDS.md)

---

Poslední aktualizace: 16.1.2026
