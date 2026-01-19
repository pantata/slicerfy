# IFS Příkazy - Kompletní Dokumentace

## Přehled

IFS (Intelligent Filament System) kontrolér nabízí řadu příkazů pro správu vícematerialového systému. Všechny příkazy jsou dostupné v Klipperu a lze je volat přímo nebo přes obálková makra.

## Struktura Parametrů

Všechny parametry se předávají ve formátu: `PARAMETER=value`

Příklady:
```gcode
IFS_F10 PRUTOK=1 LEN=90 SPEED=1200
IFS_F11 PRUTOK=2 LEN=100 SPEED=1500 WAIT=1 CHECK=1
```

---

## Základní IFS Příkazy

### 1. IFS_F10 - Zavedení Filamentu (Insert)

**Popis:** Zavedení filamentu do IFS systému

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| PRUTOK | 1 | 1-4 | Číslo portu/slotu |
| LEN | 90 | 10-500 | Délka vedení filamentu [mm] |
| SPEED | 1200 | 100-2000 | Rychlost vedení [mm/min] |
| WAIT | 1 | 0-1 | Čekat na dokončení (blokující) |
| CHECK | 0 | 0-1 | Kontrolovat dosažení hlavi |
| SLEEP | 0 | 0-1 | Jen čekat bez kontroly |

**Příklady:**
```gcode
; Základní zavedení
IFS_F10 PRUTOK=1

; Zavedení s vlastní délkou a rychlostí
IFS_F10 PRUTOK=2 LEN=120 SPEED=800

; Bez čekání (asynchronní)
IFS_F10 PRUTOK=3 WAIT=0

; S kontrolou dosažení hlavi
IFS_F10 PRUTOK=1 LEN=90 CHECK=1

; Jen čekání (pro ladění)
IFS_F10 PRUTOK=1 SLEEP=1
```

**Wrapper Makro:**
```gcode
_MMU_INSERT_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0
```

---

### 2. IFS_F11 - Vytažení Filamentu (Remove/Extract)

**Popis:** Vytažení filamentu z IFS systému

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| PRUTOK | 1 | 1-4 | Číslo portu/slotu |
| LEN | 90 | 10-500 | Délka vytažení [mm] |
| SPEED | 1200 | 100-2000 | Rychlost vytažení [mm/min] |
| WAIT | 1 | 0-1 | Čekat na dokončení |
| CHECK | 0 | 0-1 | Kontrolovat vyjmutí hlavi |

**Příklady:**
```gcode
; Základní vytažení
IFS_F11 PRUTOK=1

; Vytažení s vlastními parametry
IFS_F11 PRUTOK=2 LEN=100 SPEED=1500 CHECK=1

; Bez čekání
IFS_F11 PRUTOK=1 WAIT=0

; Dlouhé vytažení
IFS_F11 PRUTOK=3 LEN=150 SPEED=800
```

**Wrapper Makro:**
```gcode
_MMU_REMOVE_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0
```

---

### 3. IFS_F23 - Označit Filament Jako Zavedený

**Popis:** Oznámení IFS, že filament byl úspěšně zavedený do hlavi

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| PRUTOK | 1 | 1-4 | Číslo portu/slotu |
| WAIT | 1 | 0-1 | Čekat na dokončení |

**Příklady:**
```gcode
; Označit aktuální port
IFS_F23

; Označit konkrétní port bez čekání
IFS_F23 PRUTOK=2 WAIT=0
```

**Wrapper Makro:**
```gcode
_MMU_MARK_INSERTED PRUTOK=1 WAIT=1
```

---

### 4. IFS_F24 - Upnout Filament (Clamp)

**Popis:** Upnutí/sevření filamentu v IFS (zabránění pohybu)

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| PRUTOK | 1 | 1-4 | Číslo portu/slotu |
| WAIT | 1 | 0-1 | Čekat na dokončení |

**Příklady:**
```gcode
; Upnout filament v portu 1
IFS_F24 PRUTOK=1

; Upnout bez čekání
IFS_F24 PRUTOK=2 WAIT=0
```

**Wrapper Makro:**
```gcode
_MMU_FILAMENT_CLAMP PRUTOK=1 WAIT=1
```

---

### 5. IFS_F39 - Uvolnit Filament (Release/Purge)

**Popis:** Uvolnění filamentu v IFS (opak IFS_F24)

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| PRUTOK | 1 | 1-4 | Číslo portu/slotu |
| WAIT | 1 | 0-1 | Čekat na dokončení |

**Příklady:**
```gcode
; Uvolnit filament v portu 1
IFS_F39 PRUTOK=1

; Uvolnit bez čekání
IFS_F39 PRUTOK=2 WAIT=0
```

**Wrapper Makro:**
```gcode
_MMU_FILAMENT_PURGE PRUTOK=1 WAIT=1
```

---

### 6. IFS_F15 - Reset Řídící Jednotky

**Popis:** Resetování HW kontroléru IFS (při chybě, zaseknutí)

**Parametry:**
Bez parametrů

**Příklady:**
```gcode
; Reset jednotky
IFS_F15

; Reset z makra
_MMU_DRIVER_RESET
```

**Poznámka:** Používejte pouze v případě zaseknutí nebo chyby!

---

### 7. IFS_F18 - Uvolnit Všechny Filamenty

**Popis:** Uvolnění všech filamentů najednou (čištění IFS)

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| WAIT | 1 | 0-1 | Čekat na dokončení |

**Příklady:**
```gcode
; Uvolnit všechny
IFS_F18

; Bez čekání
IFS_F18 WAIT=0
```

**Wrapper Makro:**
```gcode
_MMU_PURGE_ALL WAIT=1
```

---

### 8. IFS_F112 - Zastavit Pohyb Filamentu

**Popis:** Nouzové zastavení pohybu filamentu (STOP)

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| WAIT | 0 | 0-1 | Čekat na dokončení |

**Příklady:**
```gcode
; Zastavit pohyb
IFS_F112

; Se čekáním
IFS_F112 WAIT=1
```

**Wrapper Makro:**
```gcode
_MMU_STOP_FEED WAIT=0
```

---

### 9. IFS_F13 - Zjistit Stav IFS

**Popis:** Dotaz na aktuální stav IFS jednotky

**Parametry:**
Bez parametrů

**Příklady:**
```gcode
; Zjistit stav
IFS_F13
```

**Výstup:**
Informace o stavu všech portů, senzorů, teploty atd.

**Wrapper Makro:**
```gcode
_MMU_GET_STATUS
```

---

## Vyšší Úroveň - Proprietární Příkazy

Tyto příkazy jsou specifické pro Bambu Lab a integrují se s IFS:

### PURGE_PRUTOK_IFS
Čistění filamentu z IFS do extruderu

**Wrapper Makro:**
```gcode
_MMU_PURGE_TO_EXTRUDER LENGTH=100
```

### REMOVE_PRUTOK_IFS
Odstranění filamentu z konkrétního slotu

**Wrapper Makro:**
```gcode
_MMU_REMOVE_BY_SLOT SLOT=0
```

### INSERT_PRUTOK_IFS
Zavedení filamentu z konkrétního slotu

**Wrapper Makro:**
```gcode
_MMU_INSERT_BY_SLOT SLOT=0
```

### SET_CURRENT_PRUTOK
Nastavení aktivního filamentu v Klipperu

**Wrapper Makro:**
```gcode
_MMU_SET_CURRENT_TOOL SLOT=0
```

### IFS_MOTION
Kontrola pohybu filamentu

**Wrapper Makro:**
```gcode
_MMU_CHECK_MOTION
```

---

## Příklady Typických Sekvencí

### Typická Výměna Filamentu

```gcode
; 1. Retrakce a řezání
G91
G0 E-20 F300  ; Retrakt
G90

; 2. Vytažení z IFS
IFS_F11 PRUTOK=1 LEN=90 SPEED=1200 CHECK=1

; 3. Zavedení nového
IFS_F10 PRUTOK=2 LEN=90 SPEED=1200 CHECK=1

; 4. Označení a uvolnění
IFS_F23 PRUTOK=2
IFS_F39 PRUTOK=2
```

### Čistění IFS

```gcode
; Uvolnit všechny filamenty
IFS_F18

; Resetovat kontrolér
IFS_F15

; Zjistit stav
IFS_F13
```

### Nouzové Zastavení

```gcode
; Zastavit pohyb
IFS_F112

; Resetovat jednotku
IFS_F15

; Zjistit co se stalo
IFS_F13
```

---

## Kodování Portů vs. Slotů

| Port | Slot | Poznámka |
|------|------|----------|
| 1 | 0 | První filament |
| 2 | 1 | Druhý filament |
| 3 | 2 | Třetí filament |
| 4 | 3 | Čtvrtý filament |

**Port** = fyzický port v IFS jednotce (číslo 1-4)
**Slot** = virtuální číslo v Klipperu (číslo 0-3)

Převod: `port = slot + 1` nebo `slot = port - 1`

---

## Chybové Stavy aTimeout

### Timeout Hodnoty
- Standardní operace: 120 sekund
- IFS_F18 (čištění): 10 sekund
- Kontrola stavu: 5 sekund

### Opakování (Retry)
- Defaultní počet pokusů: 3
- Konfigurováno v: `retry_count` v zmod_ifs.py

### Chybové Kódy
- RET_OK (0): Vše OK
- RET_EXTRUDER (1): Chyba senzoru extruderu
- RET_SILK (2): Chyba senzoru IFS
- RET_STALL (3): Filament se nezavedl
- RET_TIMEOUT (4): Timeout operace
- RET_EXIT (5): Konec programu
- RET_RETRY (6): Opakovat request

---

## Bezpečnost a Doporučení

### Pořadí Operací
1. **Upnout aktuální** (IFS_F24)
2. **Vytáhnout** (IFS_F11)
3. **Zavedení nového** (IFS_F10)
4. **Označit jako zavedený** (IFS_F23)
5. **Uvolnit** (IFS_F39)

### Kdy Použít CHECK
- CHECK=1 při kritických operacích (zavedení do hlavi)
- CHECK=0 v normálních situacích

### Parametry pro Různé Materiály

| Materiál | LEN | SPEED | Poznámka |
|----------|-----|-------|----------|
| PLA | 90 | 1200 | Standardní |
| PETG | 100 | 1000 | Pomalejší |
| TPU | 80 | 800 | Flexibilní |
| ABS | 110 | 900 | Horší trakce |
| Silk | 95 | 1000 | Jemný |

---

## Diagnostika a Ladění

### Zjistit Stav IFS
```gcode
IFS_F13
```

Zobrazí:
- Stav všech portů
- Detekci senzorů
- Aktuální pozici
- Chyby a upozornění

### Kontrola Pohybu
```gcode
; Zkusit zavedení bez čekání
IFS_F10 PRUTOK=1 WAIT=0

; Zjistit stav
G4 P1000
IFS_F13
```

### Reset po Chybě
```gcode
; Zastavit
IFS_F112

; Resetovat
IFS_F15

; Zjistit stav
IFS_F13

; Pokusit se znovu
IFS_F10 PRUTOK=1
```

---

## Poznámky

- Všechny parametry jsou **case-insensitive** (PRUTOK, prutok, Prutok jsou stejné)
- Výchozí hodnoty se aplikují, pokud parametr není uveden
- Operace s WAIT=1 jsou blokující (čekají na hotovo)
- Operace s WAIT=0 jsou neblokující (asynchronní)
- CHECK=1 je pomalejší ale bezpečnější

---

## Integrace do Makr - Wrapper Makra

Klipper neposílá přesně IFS příkazy, ale přes obálková makra. Všechna wrapper makra jsou nyní nakonfigurována tak, aby **přijímala stejné parametry** jako podkladové IFS příkazy a předávala je dál.

### Dostupná Wrapper Makra

#### MMU_CHANGE_TOOL (Hlavní Makro)
Centrální makro pro výměnu filamentu s podporou custom parametrů z PrusaSlic3ru

```gcode
; Základní použití (bez parametrů - použije defaults)
MMU_CHANGE_TOOL TOOL=1

; S teplou trysky
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220

; S parametry zavedení/vytažení
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=220 INSERT_LEN=110 INSERT_SPEED=800 REMOVE_LEN=100 REMOVE_SPEED=1200

; Příklady pro různé materiály:
; PLA
MMU_CHANGE_TOOL TOOL=0 HOTEND_TEMP=210 INSERT_LEN=90 INSERT_SPEED=1200 REMOVE_LEN=90 REMOVE_SPEED=1200

; TPU (pomalejší)
MMU_CHANGE_TOOL TOOL=1 HOTEND_TEMP=230 INSERT_LEN=80 INSERT_SPEED=800 REMOVE_LEN=80 REMOVE_SPEED=800

; PETG
MMU_CHANGE_TOOL TOOL=2 HOTEND_TEMP=240 INSERT_LEN=100 INSERT_SPEED=1000 REMOVE_LEN=100 REMOVE_SPEED=1000

; Silk/speciální
MMU_CHANGE_TOOL TOOL=3 HOTEND_TEMP=235 INSERT_LEN=95 INSERT_SPEED=900 REMOVE_LEN=95 REMOVE_SPEED=900
```

**Parametry:**
| Parametr | Default | Rozsah | Popis |
|----------|---------|--------|-------|
| TOOL | 0 | 0-3 | Slot/nástroj (0-3) |
| HOTEND_TEMP | 0* | 0-300 | Teplota extruderu (°C), 0=použij aktuální |
| INSERT_LEN | 0* | 0-500 | Délka zavedení filamentu [mm], 0=90 |
| INSERT_SPEED | 0* | 0-2000 | Rychlost zavedení [mm/min], 0=1200 |
| REMOVE_LEN | 0* | 0-500 | Délka vytažení filamentu [mm], 0=90 |
| REMOVE_SPEED | 0* | 0-2000 | Rychlost vytažení [mm/min], 0=1200 |

*0 = použij defaultní hodnotu

---

#### _MMU_INSERT_FILAMENT
Zavedení filamentu přes IFS_F10
```gcode
; Použití:
_MMU_INSERT_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0 SLEEP=0

; Příklady:
_MMU_INSERT_FILAMENT SLOT=1                    ; Slot 1 (port 2), defaultní parametry
_MMU_INSERT_FILAMENT SLOT=0 LEN=120 SPEED=800 ; Slot 0, delší zavedení, pomalejší
_MMU_INSERT_FILAMENT SLOT=2 WAIT=0             ; Bez čekání (asynchronní)
_MMU_INSERT_FILAMENT SLOT=1 CHECK=1            ; S kontrolou hlavi
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| SLOT | 0 | Slot 0-3 (konvertuje na port 1-4) |
| LEN | 90 | Délka vedení [mm] |
| SPEED | 1200 | Rychlost [mm/min] |
| WAIT | 1 | Čekat na hotovo |
| CHECK | 0 | Kontrolovat hlavu |
| SLEEP | 0 | Jen čekání |

---

#### _MMU_REMOVE_FILAMENT
Vytažení filamentu přes IFS_F11
```gcode
; Použití:
_MMU_REMOVE_FILAMENT SLOT=0 LEN=90 SPEED=1200 WAIT=1 CHECK=0

; Příklady:
_MMU_REMOVE_FILAMENT SLOT=1                   ; Slot 1, standardní
_MMU_REMOVE_FILAMENT SLOT=0 LEN=120 SPEED=800 ; Delší vytažení
_MMU_REMOVE_FILAMENT SLOT=2 CHECK=1           ; S kontrolou vyjmutí
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| SLOT | 0 | Slot 0-3 |
| LEN | 90 | Délka vytažení [mm] |
| SPEED | 1200 | Rychlost [mm/min] |
| WAIT | 1 | Čekat na hotovo |
| CHECK | 0 | Kontrolovat hlavu |

---

#### _MMU_MARK_INSERTED
Označit filament jako zavedený přes IFS_F23
```gcode
; Použití:
_MMU_MARK_INSERTED PRUTOK=1 WAIT=1

; Příklady:
_MMU_MARK_INSERTED                   ; Port 1 (default), s čekáním
_MMU_MARK_INSERTED PRUTOK=2 WAIT=0  ; Port 2, bez čekání
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| PRUTOK | 1 | Port 1-4 |
| WAIT | 1 | Čekat na hotovo |

---

#### _MMU_FILAMENT_CLAMP
Upnout filament přes IFS_F24
```gcode
_MMU_FILAMENT_CLAMP PRUTOK=1 WAIT=1

; Příklady:
_MMU_FILAMENT_CLAMP                  ; Port 1, standardní
_MMU_FILAMENT_CLAMP PRUTOK=2 WAIT=0 ; Port 2, bez čekání
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| PRUTOK | 1 | Port 1-4 |
| WAIT | 1 | Čekat na hotovo |

---

#### _MMU_FILAMENT_PURGE
Uvolnit filament přes IFS_F39
```gcode
_MMU_FILAMENT_PURGE PRUTOK=1 WAIT=1

; Příklady:
_MMU_FILAMENT_PURGE                  ; Port 1, standardní
_MMU_FILAMENT_PURGE PRUTOK=2 WAIT=0 ; Port 2, bez čekání
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| PRUTOK | 1 | Port 1-4 |
| WAIT | 1 | Čekat na hotovo |

---

#### _MMU_PURGE_ALL
Uvolnit všechny filamenty přes IFS_F18
```gcode
_MMU_PURGE_ALL WAIT=1

; Příklady:
_MMU_PURGE_ALL       ; Standardní s čekáním
_MMU_PURGE_ALL WAIT=0 ; Bez čekání
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| WAIT | 1 | Čekat na hotovo |

---

#### _MMU_STOP_FEED
Zastavit pohyb filamentu přes IFS_F112
```gcode
_MMU_STOP_FEED WAIT=0

; Příklady:
_MMU_STOP_FEED      ; Bez čekání (default)
_MMU_STOP_FEED WAIT=1 ; Se čekáním
```

**Parametry:**
| Parametr | Default | Popis |
|----------|---------|-------|
| WAIT | 0 | Čekat na hotovo |

---

#### _MMU_DRIVER_RESET
Reset řídící jednotky přes IFS_F15
```gcode
_MMU_DRIVER_RESET  ; Bez parametrů
```

---

#### _MMU_GET_STATUS
Zjistit stav IFS přes IFS_F13
```gcode
_MMU_GET_STATUS  ; Bez parametrů
```

---

### Příklady Typické Výměny S Parametry

```gcode
; Vytažení z portu 1 (slot 0)
_MMU_REMOVE_FILAMENT SLOT=0 LEN=100 SPEED=1200 CHECK=1

; Zavedení z portu 2 (slot 1) - pomalejší
_MMU_INSERT_FILAMENT SLOT=1 LEN=110 SPEED=800

; Označit a uvolnit
_MMU_MARK_INSERTED PRUTOK=2 WAIT=1
_MMU_FILAMENT_PURGE PRUTOK=2 WAIT=1

; Kontrola stavu
_MMU_GET_STATUS
```

---

Viz [mmu_ad5x.cfg](mmu_ad5x.cfg) pro kompletní implementaci wrapper maker.

