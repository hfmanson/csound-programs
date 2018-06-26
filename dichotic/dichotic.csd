<CsoundSynthesizer>
<CsOptions>
-d -odac -+rtmidi=virtual -M0
</CsOptions>
<CsInstruments>
/* ksmps needs to be an integer div of ifftsize */
/* Traditional dichotic pitch algorithm */
/* see https://web.stanford.edu/~bobd/cgi-bin/research/dpDemos/dichoticPitch.php */
sr                  = 44100
ksmps               = 64
nchnls              = 2

gklow               = 440
gkhigh              = 440

                    instr 1
ifftsize            = 8192  ; FFT size 
ibw                 = sr / ifftsize ; bin bandwidth
kcnt                init 0    ; counting vars
kIn[]               init ifftsize  ; input buffer
kbeta               invalue "beta"
a1                  noise 32000, kbeta ; audio input

                    if kcnt == ifftsize then  
kSpec[]             rfft kIn
                    /* flip phase between gklow and gkhigh */
ki                  = int(gklow/ibw)
                    until ki >= int(gkhigh/ibw) do
kSpec[ki + 1]       = -kSpec[ki + 1]
ki                  += 2
				od
kRow[]              rifft kSpec
kRow2[]             = kIn
                    /* update counters */ 
kcnt                = 0  
                    endif
                    
				/* shift audio in/out of buffers */
kIn                 shiftin a1
klefton             invalue "lefton"
krighton            invalue "righton"
aleft               shiftout kRow
aright              shiftout kRow2
outs                aleft * klefton, aright * krighton

                    /* increment counter */
                    kcnt += ksmps
endin

                    instr 2
                    gklow = p4 - 30
                    gkhigh = p4 + 30
                    endin

                    instr 3
                    gklow = 440
                    gkhigh = 440
                    endin

                    instr         130
knotelength         init          0
knoteontime         init          0
kcps                init          0
                    massign       0, 0
kstatus, kchan, kdata1, kdata2    midiin

                    if (kstatus == 128) then
knoteofftime        times
knotelength         =             (knoteofftime - knoteontime) * 1000
                    printks        "Note Off: chan = %f note#  = %f velocity = %f length = %f\\n", 0, kchan, kdata1,kdata2, knotelength
                    elseif (kstatus == 144) then
                    if (kdata2 == 0) then
knoteofftime        times
knotelength         =             (knoteofftime - knoteontime) * 1000
                    printk2       knotelength
                    printks       "Note Off: chan = %f note#  = %f velocity = %f length = %f\\n", 0, kchan, kdata1, kdata2, knotelength
                    gklow = 440
                    gkhigh = 440
                    else
kcps                cpsmidinn     kdata1
                    printks       "Note On: chan = %f note#  = %f velocity = %f %f\\n", 0, kchan, kdata1, kdata2, kcps
                    gklow = kcps - 30
                    gkhigh = kcps + 30
knoteontime         times
                    endif
                    elseif (kstatus == 176) then
                    if (kdata1 == 1) then
                    printks       "kchan = %f, \\t ( data1 , kdata2 ) = ( %f, %f )\\tcc1\\n", 0, kchan, kdata1, kdata2/128.0
                    else
                    printks       "kchan = %f, \\t ( data1 , kdata2 ) = ( %f, %f )\\tcc2\\n", 0, kchan, kdata1, kdata2/128.0
                    endif
                    elseif (kstatus == 224) then
                    printks       "kchan = %f, \\t ( data1 , kdata2 ) = ( %f, %f )\\tPitch Bend\\n", 0, kchan, kdata1, kdata2/128.0

                    endif
                    endin


</CsInstruments>
<CsScore>
i1 0 300
i130 0 300
i2 0 1 659.255114
i2 1 1 830.609395
i2 2 1 987.766603
i2 3 1 830.609395
i2 4 1 659.255114
i3 6 1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>132</width>
 <height>600</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>lefton</objectName>
  <x>32</x>
  <y>412</y>
  <width>20</width>
  <height>20</height>
  <uuid>{0f81185d-6c9c-44ed-9fa7-2af8f437aed3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBCheckBox" version="2">
  <objectName>righton</objectName>
  <x>32</x>
  <y>450</y>
  <width>20</width>
  <height>20</height>
  <uuid>{c90bbede-23da-44b8-998e-2e292f0e1513}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button2</objectName>
  <x>32</x>
  <y>330</y>
  <width>100</width>
  <height>30</height>
  <uuid>{db13ba5a-c394-454c-942c-032d5aaecbec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Note On</text>
  <image>/</image>
  <eventLine>i2 0 1 391.995436</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject type="BSBButton" version="2">
  <objectName>button3</objectName>
  <x>32</x>
  <y>370</y>
  <width>100</width>
  <height>30</height>
  <uuid>{10a9842a-07eb-400c-9cb7-1de66b02f997}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>event</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Note Off</text>
  <image>/</image>
  <eventLine>i3 0 1</eventLine>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>412</y>
  <width>80</width>
  <height>25</height>
  <uuid>{39b093c5-b654-4412-bfea-a3f807dfe890}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Left</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>50</x>
  <y>450</y>
  <width>80</width>
  <height>25</height>
  <uuid>{51983434-9f9a-406e-b97a-18fbef4769a4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Right</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBVSlider" version="2">
  <objectName>beta</objectName>
  <x>300</x>
  <y>100</y>
  <width>20</width>
  <height>500</height>
  <uuid>{0ff4bff7-1e16-4dc3-849d-06883d96f283}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.99600000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
