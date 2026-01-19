# Shrnutí implementace inteligentní obsluhy senzorů

## Co bylo implementováno

### 1. **Dokumentace senzorů v mmu_ad5x.cfg** (Sekce 1a)
   - Detailné vysvětlení všech potřebných senzorů
   - Doporučená konfigurace (motion sensory)
   - Popis chování při detekci
   - Pokyny na instalaci

### 2. **Detekce filamentu v hlavě** (_MMU_DETECT_FILAMENT_IN_HEAD)
   - Automaticky určuje, ze kterého slotu je filament v trysce
   - Používá motion sensory (fallback na switch sensory)
   - Volá se OPCIONÁLNĚ v START_PRINT (lze odkomentovat)
   - Výstup: uloží `mmu_detected_slot` a `mmu_current_tool`

### 3. **Ověření zavedení** (_MMU_VERIFY_LOAD)
   - Kontrola že filament skutečně prošel do extruderu
   - Používá motion nebo switch sensor
   - Vyvolá chybu pokud ověření selhane
   - Volá se v MMU_CHANGE_TOOL (LOAD fáze) a START_PRINT
   - Parametr TIMEOUT pro budoucnost (10+ sekund)

### 4. **Ověření vyjmutí** (_MMU_VERIFY_UNLOAD)
   - Kontrola že filament byl skutečně vytažen
   - Ověří absenci filamentu v senzoru extruderu
   - Vyvolá chybu pokud filament zbývá
   - Volá se v MMU_CHANGE_TOOL (UNLOAD fáze)

### 5. **Runout během tisku - extruder** (_MMU_RUNOUT_HEAD)
   - Automaticky se volá když motion sensor detekuje konec
   - Inteligentní logika: kontrola backup filamentu
   - Pokud je v MMU filament → měkký retrakt + pokračování
   - Pokud není → PAUSE s reason "runout_no_backup"
   - Zapojení: `runout_gcode: _MMU_RUNOUT_HEAD` v sensor config

### 6. **Runout během tisku - MMU** (_MMU_RUNOUT_MOTION)
   - Detekuje konec filamentu v IFS jednotce (motion sensor)
   - Automatický pokus _MMU_CONSUME_FILAMENT
   - Poté PAUSE pro výměnu
   - Zapojení: sensor config motion sensoru v MMU

### 7. **Runout v jednotlivém slotu** (_MMU_RUNOUT_SLOT)
   - Per-slot detekce (slot 0-3)
   - Spustí se jen pokud je aktivní daný slot
   - Pokus čistit zbýtek (CONSUME)
   - Zapojení: `runout_gcode: _MMU_RUNOUT_SLOT SLOT=X`

### 8. **Čištění zbývajícího filamentu** (_MMU_CONSUME_FILAMENT)
   - POOP (Purge Out Of Purge) mechanismus
   - Pumping loop: E+10 → pauza → E-10 → opakuj
   - Parametry: ITERATIONS (10), LENGTH (10mm), SPEED (100)
   - Monitoruje senzor a zastaví se když je filament vyvíjený
   - Automaticky disabluje/enableuje senzor během čištění
   - Volá se z _MMU_RUNOUT_MOTION a lze ji zavolat ručně

### 9. **Detekce vložení filamentu** (_MMU_INSERT_DETECTED)
   - Volá se když switch sensor detekuje vložení
   - Loguje které filament byl vložen
   - Připraveno pro budoucí automatické zavedení
   - Zapojení: `insert_gcode: _MMU_INSERT_DETECTED SLOT=X`

### 10. **Integrování do MMU_CHANGE_TOOL**
   - UNLOAD fáze: po IFS odebrání → _MMU_VERIFY_UNLOAD
   - LOAD fáze: po IFS značení → _MMU_VERIFY_LOAD
   - Vyvolání chyby pokud ověření selhane

### 11. **Integrování do START_PRINT**
   - OPCIONÁLNÍ: _MMU_DETECT_FILAMENT_IN_HEAD (zakomentováno)
   - Na konci zavedení: _MMU_VERIFY_LOAD
   - Kontrola přítomnosti senzorů (failsafe)

---

## Klíčové vlastnosti

### ✓ Robustnost
- Všechna makra kontrolují, zda senzory existují
- Failsafe chování (bez sensoru = jen loggování)
- Ověření bezpečnosti při zavedení/vyjmutí

### ✓ Inteligence
- Detekce backup filamentu v MMU
- Automatické čištění zbytků
- Detekce které slotu je filament

### ✓ Bezpečnost
- Chyba pokud ověření zavedení selhane
- Chyba pokud filament zbývá při unloadu
- PAUSE místo ERROR pro runouty během tisku

### ✓ Flexibilita
- Parametry: ITERATIONS, LENGTH, SPEED pro CONSUME
- TIMEOUT pro VERIFY_LOAD (pro budoucnost)
- Support pro motion i switch sensory

### ✓ Dokumentace
- Detailní inline komentáře v każém makru
- Externe: SENSOR_CONFIGURATION.md s příklady
- Konfigurace v samotném mmu_ad5x.cfg sekce 1a

---

## Soubory

1. **mmu_ad5x.cfg** - Hlavní konfigurace
   - +50 řádků dokumentace senzorů
   - 8 nových/vylepšených sensor maker
   - Integrace do MMU_CHANGE_TOOL a START_PRINT
   - Celkem: 1133 řádků

2. **SENSOR_CONFIGURATION.md** - Návod
   - Přehled senzorů
   - Doporučená konfigurace (motion i switch)
   - Diagram toku
   - Testování a ladění
   - FAQ

---

## Příští kroky (volitelné)

1. **Kalibraci senzorů**
   - Ověřit fyzickou polohu na tiskárně
   - Měřit napětí a ověřit prahové hodnoty

2. **Optimalizaci parametrů**
   - ITERATIONS v CONSUME (zkoušet 8-15)
   - LENGTH v CONSUME (zkoušet 5-15mm)
   - detection_length v sensor config (doporučeno 10mm)

3. **Přidání dalších funkcí** (v budoucnu)
   - Timeout detekce v _MMU_DETECT_FILAMENT_IN_HEAD
   - Logging do souboru runoutů
   - Kalibrace senzoru s kontrolou napětí

---

## Testování

Doporučený postup testování:

```gcode
# 1. Ověřit senzory existují
QUERY_FILAMENT_SENSOR SENSOR=extruder_sensor
QUERY_FILAMENT_SENSOR SENSOR=mmu_sensor_0

# 2. Test zavedení
T0  # Měl by projít ověření zavedení

# 3. Test vyjmutí
T1  # Měl by projít ověření vyjmutí

# 4. Test detekce
_MMU_DETECT_FILAMENT_IN_HEAD

# 5. Test čištění
_MMU_CONSUME_FILAMENT ITERATIONS=3

# 6. Test START_PRINT
START_PRINT INITIAL_TOOL=0 NOZZLE_TEMP=220 BED_TEMP=70
```

---

## Poznámky

- Všechna makra jsou odolná vůči chybějícím senzorům (fallback na logování)
- Senzory MUSÍ mít přesná jména: `extruder_sensor`, `mmu_sensor_0-3`
- Motion sensory jsou doporučeny pro lepší detekci
- Runout_gcode se spouští AUTOMATICKY z sensor config - není potřeba volat ručně
