# Architekturní Změny - MMU_CHANGE_TOOL se Custom Parametry

## 📝 Shrnutí Změn

Architektura byla upravena pro integraci s PrusaSlic3rem. Místo stanoveného procesu výměny nástrojů nyní MMU_CHANGE_TOOL přijímá kompletní parametry pro každý filament.

---

## 🔄 Původní Architektura

```
T0-T3 (přední vrstva)
  ↓
MMU_CHANGE_TOOL (s fixní logikou)
  ├─ Vytažení: vždy LEN=90, SPEED=1200
  ├─ Zavedení: vždy LEN=90, SPEED=1200
  └─ Teplota: z aktuální target teploty
```

**Problém:** Bez flexibility pro různé materiály, všechny parametry hardcoded

---

## ✨ Nová Architektura

```
PrusaSlic3r (tool change G-code)
  ↓
MMU_CHANGE_TOOL (s flexibilními parametry)
  ├─ TOOL: číslo nástroje (0-3)
  ├─ HOTEND_TEMP: teplota dle filamentu
  ├─ INSERT_LEN: délka zavedení
  ├─ INSERT_SPEED: rychlost zavedení
  ├─ REMOVE_LEN: délka vytažení
  └─ REMOVE_SPEED: rychlost vytažení
```

**Výhody:**
- ✅ Flexibilita pro různé materiály
- ✅ Přesné kontroly z slic3ru
- ✅ Optimalizace pro konkrétní filament
- ✅ Zachování kompatibility (vše má defaults)

---

## 📋 Konkrétní Změny

### 1. Příkazy T0-T3
**Staré chování:**
```gcode
[gcode_macro T0]
gcode:
    MMU_CHANGE_TOOL TOOL=0
```

**Nové chování:**
```gcode
[gcode_macro T0]
description: Rezervováno pro custom G-code (PrusaSlic3r) - nepoužívat přímo
gcode:
    # Toto makro je voláno z custom G-code v PrusaSlic3ru
    # Parametry jsou předány přes MMU_CHANGE_TOOL
```

**Důvod:** T0-T3 se již nevolají přímo, používají se jako placeholders. Všechny akce jdou přes `MMU_CHANGE_TOOL` s parametry.

---

### 2. MMU_CHANGE_TOOL Parametry

**Staré parametry:**
```
TOOL: 0
```

**Nové parametry:**
```
TOOL: 0              # Virtuální slot (0-3)
HOTEND_TEMP: 0      # Teplota extruderu (0=aktuální)
INSERT_LEN: 0       # Délka zavedení (0=90mm default)
INSERT_SPEED: 0     # Rychlost zavedení (0=1200 default)
REMOVE_LEN: 0       # Délka vytažení (0=90mm default)
REMOVE_SPEED: 0     # Rychlost vytažení (0=1200 default)
```

**Logika:**
```python
# Pokud není zadáno (0), použij default
hotend_temp = HOTEND_TEMP if HOTEND_TEMP > 0 else current_target_temp
insert_len = INSERT_LEN if INSERT_LEN > 0 else 90
insert_speed = INSERT_SPEED if INSERT_SPEED > 0 else 1200
remove_len = REMOVE_LEN if REMOVE_LEN > 0 else 90
remove_speed = REMOVE_SPEED if REMOVE_SPEED > 0 else 1200
```

---

### 3. Fáze Výměny Filamentu

**Vytažení (UNLOAD)**
- Retrakt (-20mm)
- Snížení teploty (anti-ooze)
- Řezání
- **Vytažení s custom parametry:**
  ```gcode
  _MMU_REMOVE_FILAMENT SLOT={current_tool} LEN={remove_len} SPEED={remove_speed}
  ```

**Zavedení (LOAD)**
- Zahřívání na cílovou teplotu
- **Zavedení s custom parametry:**
  ```gcode
  _MMU_INSERT_FILAMENT SLOT={new_tool} LEN={insert_len} SPEED={insert_speed}
  ```
- Označení a ověření

---

## 🎯 Příklady Použití

### Jednoduchý Případ (bez custom parametrů)
```gcode
; Výměna na filament 1 - všechny defaults
MMU_CHANGE_TOOL TOOL=1
```

### S Teplotou
```gcode
; Výměna na PETG (vyšší teplota)
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=240
```

### Kompletní Specifikace
```gcode
; TPU (pomalejší, jemněji)
MMU_CHANGE_TOOL TOOL=2 HOTEND_TEMP=230 \
  INSERT_LEN=80 INSERT_SPEED=800 \
  REMOVE_LEN=80 REMOVE_SPEED=800
```

### Z PrusaSlic3ru
```gcode
; Automaticky vygenerováno ze slic3ru
MMU_CHANGE_TOOL TOOL={next_filament_num} HOTEND_TEMP={next_extruder_temp}
```

---

## 🔗 Integrace s PrusaSlic3rem

Viz [PRUSASLICER_INTEGRATION.md](PRUSASLICER_INTEGRATION.md) pro úplný návod.

**Minimální Setup:**
```gcode
; V PrusaSlic3r → Print Settings → Tool change G-code
MMU_CHANGE_TOOL TOOL={next_filament_num} HOTEND_TEMP={next_extruder_temp}
```

**Advanced Setup:**
```gcode
; S material-specific parametry
{% if next_filament_num == 0 %}
  MMU_CHANGE_TOOL TOOL=0 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=90 INSERT_SPEED=1200
{% elsif next_filament_num == 1 %}
  MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP={next_extruder_temp} INSERT_LEN=80 INSERT_SPEED=800
{% endif %}
```

---

## ⚙️ Technické Detaily

### Výchozí Hodnoty (jsou-li parametry 0 nebo vynechány)

```
HOTEND_TEMP=0       → Použij printer.extruder.target_temperature
INSERT_LEN=0        → 90 mm
INSERT_SPEED=0      → 1200 mm/min
REMOVE_LEN=0        → 90 mm
REMOVE_SPEED=0      → 1200 mm/min
```

### Logika Zpracování v Makru

```jinja
{% set param_hotend_temp = params.HOTEND_TEMP|default(0)|int %}
{% set hotend_temp = param_hotend_temp if param_hotend_temp > 0 else printer.extruder.target_temperature|default(200)|int %}
```

### Volání IFS Příkazů

```gcode
# Vytažení s custom parametry
_MMU_REMOVE_FILAMENT SLOT={current_tool} LEN={remove_len} SPEED={remove_speed}

# Zavedení s custom parametry
_MMU_INSERT_FILAMENT SLOT={new_tool} LEN={insert_len} SPEED={insert_speed}
```

---

## 🔒 Zpětná Kompatibilita

✅ **Stará volání stále fungují:**
```gcode
; Jednoduché volání bez parametrů - použije vše jako dříve
MMU_CHANGE_TOOL TOOL=1
```

✅ **Postupné přidávání parametrů:**
```gcode
; Jen teplota
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220

; Teplota + délka
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220 INSERT_LEN=100

; Všechny parametry
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220 INSERT_LEN=100 INSERT_SPEED=1000 REMOVE_LEN=100 REMOVE_SPEED=1000
```

---

## 📊 Porovnání Starého vs. Nového

| Aspekt | Staré | Nové |
|--------|-------|------|
| **Teplota** | Fixed (target temp) | Custom (parametr) |
| **INSERT_LEN** | Fixed 90mm | Custom (default 90) |
| **INSERT_SPEED** | Fixed 1200 | Custom (default 1200) |
| **REMOVE_LEN** | Fixed 90mm | Custom (default 90) |
| **REMOVE_SPEED** | Fixed 1200 | Custom (default 1200) |
| **Flexibilita** | Nízká | Vysoká |
| **PrusaSlic3r** | Nepodporován | Plně podporován |
| **Zpětná kompatibilita** | N/A | ✅ Ano |

---

## 🚀 Migrační Cesta

### Fáze 1: Upgrade (bez změn v použití)
- Nainstalovat nový mmu_ad5x.cfg
- Všechny příkazy `MMU_CHANGE_TOOL TOOL=X` stále fungují
- Není potřeba nic měnit

### Fáze 2: Přidání Teplot
- V PrusaSlic3ru přidat HOTEND_TEMP
- Optimalizace teplot dle filamentu

### Fáze 3: Optimalizace Parametrů
- Pro TPU/flexible snížit INSERT_SPEED
- Pro PETG zvýšit REMOVE_SPEED
- Dle vašich zkušeností

### Fáze 4: Plná Integrace PrusaSlic3ru
- Nastavit všechny parametry v slic3ru
- Automatické generování perfektních G-code

---

## 📚 Dokumentace

- [mmu_ad5x.cfg](mmu_ad5x.cfg) - Zdrojový kód
- [IFS_COMMANDS.md](IFS_COMMANDS.md) - Referenční příručka IFS
- [PRUSASLICER_INTEGRATION.md](PRUSASLICER_INTEGRATION.md) - Návod PrusaSlic3r
- [DOKUMENTACE.md](DOKUMENTACE.md) - Obecná dokumentace

---

## ✅ Checklist Ověření

- [ ] Přečetl jsem [PRUSASLICER_INTEGRATION.md](PRUSASLICER_INTEGRATION.md)
- [ ] Vytvořil jsem tool change G-code v PrusaSlic3ru
- [ ] Otestoval jsem jednoduchý MMU_CHANGE_TOOL TOOL=1
- [ ] Otestoval jsem s HOTEND_TEMP parametrem
- [ ] Otestoval jsem s INSERT_LEN a INSERT_SPEED
- [ ] Spustil jsem malý test tisk s 2 barvami
- [ ] Optimalizuji parametry dle zkušenosti

---

Poslední aktualizace: 16.1.2026
