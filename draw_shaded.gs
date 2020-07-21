'reinit'
'open gpm.201811.ctl'
'set grads off'
'set grid off'

'set rgb 20 255 255 255'
'set rgb 21 181 201 255'
'set rgb 22 99 112 247'
'set rgb 23 0 99 255'
'set rgb 24 0 198 51'
'set rgb 25 99 255 0'
'set rgb 26 255 255 0'
'set rgb 27 255 198 0'
'set rgb 28 255 124 0'
'set rgb 29 255 25 0'
'set rgb 30 167 29 14'

'set gxout shaded'
'set rbcols 21 22 23 24 25 26 27 28 29 30  '
'set clevs 0.1 2 4 6 8 10 15 20 25 30'
'set lon -110 -15'
'set lat 30 70'
it=1
while(it<=288)
'set t 'it
'd prep'
'gxprint gpm_'it'.png white'

'q dims'
rec=sublin(result,5)
recs=subwrd(rec,6)
'draw title 0.5-hourly rain of 'recs' UTC'

'c'

it=it+1
endwhile
;
