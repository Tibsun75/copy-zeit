#!/bin/bash

#Bildschirm löschen
clear

# Prüfen, ob Quelle und Ziel als Argumente übergeben wurden
if [ "$#" -ne 2 ]; then
    echo "Benutzung: $0 <Quellordner> <Zielordner>"
    exit 1
fi

# Quelle (Ordner auf der Festplatte) und Ziel (SD-Karte) aus den Argumenten
SOURCE="$1"
TARGET="$2"

# Prüfen, ob die Quelle und das Ziel existieren
if [ ! -d "$SOURCE" ]; then
    echo "Fehler: Quellordner existiert nicht."
    exit 1
fi
if [ ! -d "$TARGET" ]; then
    echo "Fehler: Zielordner existiert nicht."
    exit 1
fi

# Cache löschen
echo "Leere den Cache..."
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

# Dateigröße berechnen (in MB)
echo "Berechne Dateigröße"
SIZE=$(du -sm "$SOURCE" | cut -f1)

# Zeitmessung starten
echo "Starte Zeitmessung"
START=$(date +%s)

# Kopiervorgang ausführen
echo "Kopiere Dateien"
cp --verbose -r "$SOURCE" "$TARGET"
date && echo "schreibe alle dateien im cache mit sync"
sync
date && echo "cache geschrieben"

# Zeitmessung beenden
END=$(date +%s)

# Dauer berechnen
DURATION=$((END - START))

# Übertragungsrate berechnen (MB/s)
if [ $DURATION -gt 0 ]; then
    SPEED=$(echo "scale=2; $SIZE / $DURATION" | bc)
else
    SPEED="$SIZE"
fi

# Ergebnis ausgeben
echo ""
echo ""
echo "Kopiervorgang abgeschlossen. Dauer: $DURATION Sekunden"
echo "Übertragene Datenmenge: $SIZE MB"
echo "Durchschnittliche Geschwindigkeit: $SPEED MB/s"
