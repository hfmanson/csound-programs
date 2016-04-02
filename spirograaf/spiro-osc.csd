<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
; Audio out   Audio in
-odac           -iadc    ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
; -o gen10.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>
#define WIEL #"/csound-spiro/in/wiel"#
#define GAT #"/csound-spiro/in/gat"#
#define FASE #"/csound-spiro/in/fase"#
#define FASE2 #"/csound-spiro/in/fase2"#
#define FIGS #"/csound-spiro/in/figs"#
#define CHANGE #"/csound-spiro/in/change"#

#ifndef OSCSERVER
#define OSCSERVER #"127.0.0.1"#
;#define OSCSERVER #"mansoft.nl"#
;#define OSCSERVER #"192.168.100.250"#
#end

; Initialize the global variables.
sr                  =             44100
kr                  =             1764
ksmps               =             25
nchnls              =             2

gilisten            OSCinit       7000

                    instr         11
                    OSCsend       1, $OSCSERVER, 9999, "/csound-spiro/out/inputs", "s", "gat,fase,wiel,fase2,figs,change"
                    endin
                    

; Instrument 1
; figuren met hetzelfde wiel
; luistert naar alle OSC boodschappen
                    instr         1
kwiel               init          30
iamp                init          32000
irr                 init          3.05
ifactor             init          9
ifreq               init          kr / ifactor
iringidx            init          p4
iring               table         iringidx, 6

kcnt                init          0

kgat                init          0
next1:
kans1               OSClisten     gilisten, $GAT, "f", kgat
                    if (kans1 == 0) goto done1
;                    printks      "gat = %f\\n", 0, kgat
                    kgoto         next1  ;Process all events in queue
done1:

kfase               init          0
next2:
kans2               OSClisten     gilisten, $FASE, "f", kfase
                    if (kans2 == 0) goto done2
;                    printks      "fase = %f\\n", 0, kfase
                    kgoto         next2  ;Process all events in queue
done2:

kwiel1              init          0
next3:
kans3               OSClisten     gilisten, $WIEL, "f", kwiel1
                    if (kans3 == 0) goto done3
;                    printks      "kwiel1 = %f\\n", 0, 16 * kwiel1
                    kgoto         next3  ;Process all events in queue
done3:

kfase2              init          0.5
next4:
kans4               OSClisten     gilisten, $FASE2, "f", kfase2
                    if (kans4 == 0) goto done4
;                    printks      "fase2 = %f\\n", 0, kfase2
                    kgoto         next4  ;Process all events in queue
done4:

kfigs               init          0.3
next5:
kans5               OSClisten     gilisten, $FIGS, "f", kfigs
                    if (kans5 == 0) goto done5
;                    printks      "figs = %f\\n", 0, kfigs
                    kgoto         next5  ;Process all events in queue
done5:


kwiel               table         16 * kwiel1, 3
krondjes            table         16 * kwiel1, iringidx + 4

kfreq               =             ifreq * krondjes
kwr                 =             kwiel / iring
ka                  =             1 - kwr

ktblidx             =             kcnt / ifactor % floor(kfigs*10)
kcnt                =             kcnt + 1

apha1               phasor        kfreq
kfase2a             =             kfase2 * 4 - 2
afase1              =             apha1 + ktblidx * kfase2a / iring + kfase
apha2               phasor        kfreq * (kwr - 1) / kwr
afase2              =             apha2 + ktblidx * kfase2a / iring + kfase
kb                  =             kwr - (0.0647059 * (ktblidx + kgat * 10.0 - 1.0) + 0.31) / irr
a1                  table         afase1, 1, 1, 0, 1
a2                  table         afase2, 1, 1, 0, 1
a3                  table         afase1, 2, 1, 0, 1
a4                  table         afase2, 2, 1, 0, 1
                    outs          iamp * (a1 * ka + a2 * kb), iamp * (a3 * ka + a4 * kb)
                    endin

; Instrument 2
; vaste figuren gedefinieerd in tabellen
; luistert naar 'gat' en 'fase' OSC boodschappen
                    instr         2
ifactor             init          p7
ifreq               init          kr / ifactor

kgat                init          0
next1:
kans1               OSClisten     gilisten, $GAT, "f", kgat
                    if (kans1 == 0) goto done1
;                    printks      "gat = %f\\n", 0, kgat
                    kgoto         next1  ;Process all events in queue
done1:

kfase                init          0
next2:
kans2               OSClisten     gilisten, $FASE, "f", kfase
                    if (kans2 == 0) goto done2
;                    printks      "fase = %f\\n", 0, kfase
                    kgoto         next2  ;Process all events in queue
done2:

done3:
iringidx            init          p4
iring               table         iringidx, 6
ifig                init          p5
iaantalwielen        init          p6
iamp                init          32000
irr                 init          3.05
kcnt                init          0

ktblidx             =             kcnt / ifactor % iaantalwielen
kcnt                =             kcnt + 1
kwielidx            table         ktblidx, ifig
kgat1               table         ktblidx, ifig + 1
kfase1              table         ktblidx, ifig + 2
kwiel                table          kwielidx, 3
krondjes            table         kwielidx, iringidx + 4
kfreq               =             ifreq * krondjes
kwr                 =             kwiel / iring
ka                  =             1 - kwr
apha1               phasor        kfreq
afase1              =             apha1 + kfase + kfase1 / iring
apha2               phasor        kfreq * (kwr - 1) / kwr
afase2              =             apha2 + kfase + kfase1 / iring
kb                  =             kwr - (0.0647059 * (kgat1 + kgat * 10.0 - 1.0) + 0.31) / irr
a1                  table         afase1, 1, 1, 0, 1
a2                  table         afase2, 1, 1, 0, 1
a3                  table         afase1, 2, 1, 0, 1
a4                  table         afase2, 2, 1, 0, 1
                    outs          iamp * (a1 * ka + a2 * kb), iamp * (a3 * ka + a4 * kb)
                    endin

                    instr         3
kchange             init          0
kidx                init          0
kins                init          0
kring               init          0
kfig                init          0
kaant               init          0
kfactor             init          0

next1:
kans1               OSClisten     gilisten, $CHANGE, "f", kchange
                    if (kans1 == 0) goto done1
                    if (kchange == 0) goto done1
                    printks       "change = %f\\n", 0, kchange
                    printks       "idx = %f\\n", 0, kidx
kins                table         kidx, 100
                    printks       "ins = %f\\n", 0, kins
kring               table         kidx, 101
                    printks       "ring = %f\\n", 0, kring
kfig                table         kidx, 102
                    printks       "fig = %f\\n", 0, kfig
kaant               table         kidx, 103
                    printks       "aant = %f\\n", 0, kaant
kfactor             table         kidx, 104
                    printks       "factor = %f\\n", 0, kfactor
kidx                =             (kidx + 1) % 7
                    turnoff2      1, 0, 1
                    turnoff2      2, 0, 1
                    event         "i", kins, 0, -1, kring, kfig, kaant, kfactor
                    kgoto         next1  ;Process all events in queue
done1:
                    endin
</CsInstruments>
<CsScore>
; cosinus tabel
f 1 0 16384 11 1
; sinus tabel
f 2 0 16384 10 1

; *** lookup-tables
; wielen
;            0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
f 3 0 16 -2 24 30 32 36 40 45 48 52 56 60 63 64 72 75 80 84
; aantal rondjes bij ring 96
f 4 0 16 -2  1  5  1  3  5 15  1 13  7  5 21  2  3 25  5  7
; aantal rondjes bij ring 105
f 5 0 16 -2  8  2 32 12  8  3 16 52  8  4  3 64 24  5 16  4
; ringen
f 6 0  2 -2 96 105

; *** figuren
; wielen
f 10 0 8 -2  0 14 14 14
; gaten
f 11 0 8 -2  5 13 14 15
; fases
f 12 0 8 -2  0  0  0  0

; wielen
f 13 0 16 -2  1  1  1  5  5  5  9  9  9 13 13 13
; gaten
f 14 0 16 -2  1  2  3  6  7  8 11 12 13 16 17 18
; fases
f 15 0 16 -2  0  0  0  0  0  0  0  0  0  0  0  0

; wielen
f 16 0 32 -2  4  8 14 12  0  2 11  6 14 12  0  2 11  6 12  0  2 11  6  2 11  6  6  6
; gaten
f 17 0 32 -2  5  9 15 13  1  3 11  7 15 13  1  3 11  7 13  1  3 11  7  3 11  7  7  7 
; fases
f 18 0 32 -2  0  0  0  0  0  0  0  0  8  8  8  8  8  8 16 16 16 16 16 24 24 24 32 40

; wielen
f 19 0 16 -2  1  1  1  1  1  5  5  5  5  5  9  9  9  9  9
; gaten
f 20 0 16 -2  1  2  3  4  5  1  2  3  4  5  1  2  3  4  5
; fases
f 21 0 16 -2  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0

; wielen
f 22 0 8 -2    9    9    9    9    9    9    9    9    9
; gaten
f 23 0 8 -2    1    2    3    2    3    4    5    4    5
; fases
f 24 0 8 -2    0  0.5    1 -0.5   -1  1.5    2 -1.5    2

; instrument
f 100 0 16 -2   1   1   2   2   2   2   2
; ring
f 101 0 16 -2   0   1   1   1   0   1   1
; fig
f 102 0 16 -2   0   0  10  13  16  19  22
; aant
f 103 0 16 -2   0   0   4  12  24  15   9
; factor
f 104 0 16 -2   0   0  10   1   1   1   1

i 11 0 .1
i 3 0 10000
i 2 0 -1    1  22    9      1
; 10000 keer herhalen
;r 10000
; een wiel
;ins start dur ring
;i 1      0  30    0
;i 1      +   .    1
; vaste figuren
;ins start dur ring fig aant factor
;i 2     60   5    1  10    4      10
;i 2      +   .    1  13   12      1
;i 2      +   .    0  16   24      1
;i 2      +   .    1  19   15      1
;i 2      +   .    1  22    9      1
;s
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>836</x>
 <y>57</y>
 <width>442</width>
 <height>670</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName>spiro</objectName>
  <x>5</x>
  <y>5</y>
  <width>500</width>
  <height>500</height>
  <uuid>{eac85a7f-099e-4aa8-b9ce-3757c1217596}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <value>-255.00000000</value>
  <type>lissajou</type>
  <zoomx>2.20000000</zoomx>
  <zoomy>2.20000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 836 57 442 670
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>
<MacGUI>
ioView nobackground {59367, 11822, 65535}
ioGraph {5, 5} {500, 500} lissajou 2.200000 -255 spiro
</MacGUI>
