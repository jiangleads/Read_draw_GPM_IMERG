load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

begin

                   

; Set some map information ; line and text information
  mpres = True
  mpres@mpFillOn = False
  mpres@gsnDraw = True
  mpres@gsnFrame = False
;  mpres@mpFillColors  = (/"background","DeepSkyBlue","ForestGreen","DeepSkyBlue", "transparent"/)
  mpres@mpFillColors  = (/"background","DeepSkyBlue","transparent","DeepSkyBlue", "transparent"/)
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGridLineColor             = "Black"
  
  mpres@mpPerimOn                   = False ;True
  mpres@mpLimbLineColor             = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpUSStateLineColor          = "Black"
;  mpres@tiMainString                = " WPS Domain Configuration  "

  lnres = True 
  lnres@gsLineThicknessF = 2.5
  lnres@domLineColors    = (/ "white", "Red" , "Red" , "Blue" /)

  txres = True
  txres@txFont = "helvetica-bold"
  ;txres@txJust = "BottomLeft"
  txres@txJust = "TopLeft"
  txres@txPerimOn = False
  txres@txFontHeightF = 0.015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not change anything between the ";;;;;" lines
  filename = "../../wps/namelist.wps"
  mpres@max_dom   = stringtoint  (systemfunc("grep max_dom    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@dx        = stringtofloat(systemfunc("grep dx         " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@dy        = stringtofloat(systemfunc("grep dy         " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@ref_lat   = stringtofloat(systemfunc("grep ref_lat    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@ref_lon   = stringtofloat(systemfunc("grep ref_lon    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  test = systemfunc("grep truelat1 " +filename ) 
  if ( .not. ismissing(test) )
    mpres@truelat1  = stringtofloat(systemfunc("grep truelat1   " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  else
    mpres@truelat1  = 0.0
  end if
  test = systemfunc("grep truelat2 " +filename ) 
  if ( .not. ismissing(test) )
    mpres@truelat2  = stringtofloat(systemfunc("grep truelat2   " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  else
    mpres@truelat2  = 0.0
  end if
  mpres@stand_lon = stringtofloat(systemfunc("grep stand_lon  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  
  opts = True
  opts@gsnDraw       = get_res_value_keep(opts,"gsnDraw",     True)
  opts@gsnFrame      = get_res_value_keep(opts,"gsnFrame",    False)
 
  opts@cnFillDrawOrder 			  	 = "PostDraw"				; 设置填色图绘图顺序
  opts@mpGridAndLimbOn        = True               ; turn on grid lines
  opts@mpGridAndLimbDrawOrder 		 = "PostDraw"	; 设置网格线绘图顺序
  opts@cnGridBoundPerimOn         = True
  opts@mpLabelDrawOrder 					 = "PostDraw"	; 设置地图标签绘图顺序
  opts@mpOutlineDrawOrder  		= "PostDraw"		; 设置地图轮廓绘图顺序
  opts@mpOceanFillColor 			= "white" 	; 海洋填充颜色
  opts@mpInlandWaterFillColor = "white" 		  ; 内陆水面填充颜色
 
  test = systemfunc("grep lambert " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "lambert"  
    opts@MAP_PROJ = 1  
    opts@mpProjection = "LambertConformal"
    opts@mpLambertParallel1F = mpres@truelat1
    opts@mpLambertParallel2F = mpres@truelat2
    opts@mpLambertMeridianF  = mpres@stand_lon 
  end if
  
  test = systemfunc("grep mercator " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "mercator"
    opts@MAP_PROJ = 3
    opts@mpProjection = "Mercator"
    opts@mpCenterLatF = mpres@ref_lat
    opts@mpCenterLonF = mpres@ref_lon    
  end if
  test = systemfunc("grep polar " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "polar"   
    opts@MAP_PROJ = 2 
    opts@mpProjection = "Stereographic"
    opts@mpCenterLatF = mpres@ref_lat
    opts@mpCenterLonF = mpres@ref_lon
  end if
  testa = systemfunc("grep 'lat-lon' " +filename ) 
  if ( .not. ismissing(testa) )
    mpres@map_proj          = "lat-lon"
    mpres@pole_lat = stringtofloat(systemfunc("grep pole_lat  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
    mpres@pole_lon = stringtofloat(systemfunc("grep pole_lon  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
    opts@MAP_PROJ = 6
    opts@LATINC = mpres@dy
    opts@LONINC = mpres@dx
  end if


  parent_id         = new ( mpres@max_dom , integer )
  parent_grid_ratio = new ( mpres@max_dom , integer )
  i_parent_start    = new ( mpres@max_dom , integer )
  j_parent_start    = new ( mpres@max_dom , integer )
  e_we              = new ( mpres@max_dom , integer )
  e_sn              = new ( mpres@max_dom , integer )

  do n = 1, mpres@max_dom 

    n0 = n - 1
    parent_id(n0)         = stringtoint(systemfunc("grep parent_id         " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    parent_grid_ratio(n0) = stringtoint(systemfunc("grep parent_grid_ratio " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    i_parent_start(n0)    = stringtoint(systemfunc("grep i_parent_start    " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    j_parent_start(n0)    = stringtoint(systemfunc("grep j_parent_start    " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    e_we(n0)              = stringtoint(systemfunc("grep e_we              " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    e_sn(n0)              = stringtoint(systemfunc("grep e_sn              " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
 
  end do 

  mpres@parent_id         = parent_id
  mpres@parent_grid_ratio = parent_grid_ratio
  mpres@i_parent_start    = i_parent_start
  mpres@j_parent_start    = j_parent_start
  mpres@e_we              = e_we
  mpres@e_sn              = e_sn
;  mpres@tfDoNDCOverlay                    = True          ; This is native data, so
                                                        ; no transformation needs
                                                        ; to happen.
  mpres@tfDoNDCOverlay                    = "NDCViewport" ; NCL V6.5.0 or later

 
	
    
  opts = True  
  opts@tfDoNDCOverlay                  = False
  opts@DX = mpres@dx
  opts@DY = mpres@dy
  opts@LATINC = 0.0
  opts@LONINC = 0.0

  opts@TRUELAT1 = mpres@truelat1
  opts@TRUELAT2 = mpres@truelat2
  opts@STAND_LON = mpres@stand_lon

  opts@REF_LAT = mpres@ref_lat
  opts@REF_LON = mpres@ref_lon
  if ( isatt(mpres,"ref_x") ) then
    opts@KNOWNI = mpres@ref_x
  else
    opts@KNOWNI = int2flt(mpres@e_we(0))/2.
  end if
  if ( isatt(mpres,"ref_y") ) then
    opts@KNOWNJ = mpres@ref_y
  else
    opts@KNOWNJ = int2flt(mpres@e_sn(0))/2.
  end if

  if ( isatt(mpres,"pole_lat") ) then
    opts@POLE_LAT = mpres@pole_lat
  else
    opts@POLE_LAT = 90.0
  end if
  if ( isatt(mpres,"pole_lon") ) then
    opts@POLE_LON = mpres@pole_lon
  else
    opts@POLE_LON = 0.0
  end if

  
   xx = 1.0
   yy = 1.0
   loc = wrf_ij_to_ll (xx,yy,opts)
   start_lon = loc(0)
   start_lat = loc(1)
   xx = int2flt(mpres@e_we(0))
   yy = int2flt(mpres@e_sn(0))
   loc = wrf_ij_to_ll (xx,yy,opts)
   end_lon = loc(0)
   end_lat = loc(1)
   
   opts@start_lat   = start_lat
   opts@start_lon   = start_lon
   opts@end_lat     = end_lat
   opts@end_lon     = end_lon 
  
   opts@gsnMaximize        = False     ; maximize plot in frame
;   cmap = read_colormap_file("OceanLakeLandSnow")  ; read color data
;   opts@cnFillOn           = True     ; turn on contour fill
;   opts@cnFillPalette      = cmap(1:,:)  ; set color map
   opts@cnLinesOn          = False    ; turn off contour lines
   opts@cnLineLabelsOn     = False    ; turn off line labels
   opts@cnInfoLabelOn      = False    ; turn off info label
   opts@lbBoxLinesOn       = False    ; turn off labelbar box lines
  
   opts@cnFillMode         = "RasterFill"   ; for faster draw
    

   
; Select portion of the map to view.
   opts@mpLimitMode           = "Corners"
   opts@mpLeftCornerLatF      = get_res_value_keep(opts, "mpLeftCornerLatF", opts@start_lat)
   opts@mpLeftCornerLonF      = get_res_value_keep(opts, "mpLeftCornerLonF", opts@start_lon)
   opts@mpRightCornerLatF     = get_res_value_keep(opts, "mpRightCornerLatF",opts@end_lat)
   opts@mpRightCornerLonF     = get_res_value_keep(opts, "mpRightCornerLonF",opts@end_lon)

   if ( opts@mpRightCornerLonF .lt. 0.0 ) then
     opts@mpRightCornerLonF  = opts@mpRightCornerLonF + 360.0
   end if 
; Set some map information ; line and text information

  opts@mpGridSpacingF              = 5

 










epoch_year  = 1800
epoch_month = 1
epoch_day   = 1
epoch_hour  = 0
epoch_minute = 0
epoch_second = 0
units  = "hours since "+sprinti("%i",epoch_year)+"-"+sprinti("%.2i",epoch_month)+"-"+sprinti("%.2i",epoch_day)+" "+sprinti("%.2i",epoch_hour)+":"+sprinti("%.2i",epoch_minute)+":"+sprinti("%.2i",epoch_second); "seconds/hours/days since ...."

format         = "%Y-%N-%D_%H:%M:%S"
format@units = units

;instring0       = "2023-07-28_11:00:00"
thours0 = cd_inv_string(instring0, format)

;instring1       = "2023-07-29_05:00:00"
thours1 = cd_inv_string(instring1, format)

;instring2       = "2023-07-29_04:59:00"
;thours2 = cd_inv_string(instring2, format)

  
  ;;;;;;;;;;;read data;;;;;;;;


  path = "/unsa/lzjiang/OSCER_bak/lzjiang/data/GPM_IMERG/"
  files = systemfunc("ls "+path+"*2023*.HDF5")
  nfiles=dimsizes(files)
 
  print("Number of files: " + nfiles)

; Initialize an array to store the datetime strings
timestrings_start = new(nfiles, "string")
timestrings_end = new(nfiles, "string")

; Loop through each filename to extract the datetime part (assuming the format is consistent)
do i = 0, nfiles - 1
  ; Assuming the datetime in the filenames is something like: "GPM_IMERG_YYYYMMDD_HHMM.HDF5"
  ; Modify the indices below based on the actual structure of your filenames.
  ; Example: GPM_IMERG_20231015_1230.HDF5 -> Extract 20231015_1230
;3B-HHR.MS.MRG.3IMERG.20230729-S230000-E232959.1380.V07B
  filename = files(i)
  split_name = str_split(filename, "/")          ; Split path from filename
  short_name = split_name(dimsizes(split_name)-1) ; Get the last part (filename)
  
  ; Get datetime part from filename (assuming it's between positions 12 and 26)
  
  ; Convert it into a proper format: YYYY-MM-DD_HH:MM:SS
  yyyy = str_get_cols(short_name, 21, 24)
  mm   = str_get_cols(short_name, 25, 26)
  dd   = str_get_cols(short_name, 27, 28)
  hh   = str_get_cols(short_name, 31, 32)
  mi   = str_get_cols(short_name, 33, 34)
  ss   = str_get_cols(short_name, 35, 36)

  hh2   = str_get_cols(short_name, 39, 40)
  mi2   = str_get_cols(short_name, 41, 42)
  ss2   = str_get_cols(short_name, 43, 44)
  
  timestrings_start(i) = yyyy + "-" + mm + "-" + dd + "_" + hh + ":" + mi + ":" + ss  ; Example format: "2023-10-15_12:30:00"
  timestrings_end(i) = yyyy + "-" + mm + "-" + dd + "_" + hh2 + ":" + mi2 + ":" + ss2  ; Example format: "2023-10-15_12:30:00"
  
end do


; Convert datetime strings to time in hours since the epoch
epoch_year  = 1800
epoch_month = 1
epoch_day   = 1
epoch_hour  = 0
epoch_minute = 0
epoch_second = 0
units = "hours since " + sprinti("%i",epoch_year) + "-" + sprinti("%.2i",epoch_month) + "-" + sprinti("%.2i",epoch_day) + \
        " " + sprinti("%.2i",epoch_hour) + ":" + sprinti("%.2i",epoch_minute) + ":" + sprinti("%.2i",epoch_second)

; Define the format of the datetime strings
format = "%Y-%N-%D_%H:%M:%S"
format@units = units

; Convert the datetime strings to time in hours
timehours_start = cd_inv_string(timestrings_start, format)
timehours_end = cd_inv_string(timestrings_end, format)


print("Times in hours since 1800-01-01 00:00:00: ")
;print(timehours)
 
	
  res=True


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  res@mpMinLatF=opts@start_lat -10
  res@mpMaxLatF=opts@end_lat +10
  res@mpMinLonF=opts@start_lon-10
  res@mpMaxLonF=opts@end_lon+10
  
  nl  = dimsizes(files)
  print(nl)
  grib  = addfile(path+"3B-HHR.MS.MRG.3IMERG.20230725-S040000-E042959.0240.V07B.HDF5", "r")
  ;ori  = grib->precipitationCal(:,{115:121},{23:29})
  ori  = grib->/Grid/precipitation (:,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF})
  dims  = dimsizes(ori)
  nhours  = dims(0)
  mlon  = dims(1)
  nlat  = dims(2)
	
	print(dims)
  
  rain  = new((/nlat,mlon/),"float") 
  rain_sum  = new((/nlat,mlon/),"float") 
  rain_sum = 0
  
 ; grib_in  = addfiles(files,"r")

  ;spd= smth9_Wrap(spd,0.50,0.25,False)

  ;================================================================================================
;;;;;;;;;;;;set map;;;;;;;;;;;;;;;;;;;;;;;;;
  res = True
  res@mpShapeMode = "FreeAspect"
  res@vpWidthF = 0.8
  res@vpHeightF = 0.5
  res@gsnDraw  = False  ; don't draw
  res@gsnFrame  = False  ; don't advance frame
  res@gsnLeftString  = ""
  res@gsnRightString  = ""
  res@gsnAddCyclic  = False




res_tot                      = opts
  res_tot@cnFillOn             = True
  res_tot@cnFillMode           = "RasterFill"
  res_tot@cnLinesOn            = False            ; turn off contour lines
  res_tot@cnLineLabelsOn       = False            ; turn off contour labels
  res_tot@cnFillOpacityF       = 1.               ; .85 

  ;res_tot@cnLevelSelectionMode = "ManualLevels"
  ;res_tot@cnMaxLevelValF       = 50  ;set maximum contour level  
  ;res_tot@cnMinLevelValF       =  5   ;set minimum contour level
  ;res_tot@cnLevelSpacingF      =  5 
  ;res_tot@cnFillColors = (/"White", \
                             ; "green","blue","Green","Yellow","Red","Purple"/)

  res_tot@pmLabelBarHeightF    = 0.085        ; Make labelbar less thick
  res_tot@lbLabelFontHeightF   = 0.016
  res_tot@pmLabelBarWidthF         = 0.45 ;值越小，越短
  res_tot@pmLabelBarOrthogonalPosF = 0
  res_tot@lbLabelFont = "times-roman"

  res_tot@tiMainOffsetYF = 0.0 ;越大越往上
  res_tot@tiMainFont = "times-roman"
  res_tot@tiMainFontHeightF = 0.024
  res_tot@tiMainFontThicknessF = 0.19
  res_tot@gsnStringFont           = "times-roman"
  res_tot@gsnLeftStringFontHeightF    = 0.016
  res_tot@gsnRightStringFontHeightF    = 0.024
  res_tot@gsnRightString       = "" 
 ;res_tot@gsnLeftString        =  "station data(line)"
  ;res_tot@gsnLeftString  = "era5 data(shade)"
  ;res@gsnRightString = ""
;plot=new(numFILES,graphic) 
  ;do ihour = 0,numFILES-2     ;numFILES-2   ; 0, dims(0)-2
    

  






  res_mp = res_tot
  res_mp@gsnDraw  = False  ; don't draw
  res_mp@gsnFrame  = False  ; don't advance frame
  res_mp@mpDataBaseVersion  ="MediumRes"
  res_mp@mpDataSetName  ="Earth..4"
  res_mp@mpOutlineSpecifiers  ="China:Provinces" 
  res_mp@mpOutlineOn  = True
  res_mp@mpOutlineBoundarySets  = "Geophysical"
  res_mp@mpGeophysicalLineColor  = "chocolate4"
  res_mp@mpNationalLineColor  = -1
  res_mp@mpUSStateLineColor  = "dimgray"
  res_mp@mpGridLineColor  = "dimgray"
  res_mp@mpLimbLineColor  = "Black"
  res_mp@mpPerimLineColor  = "Black"
  res_mp@mpGeophysicalLineThicknessF = 0.8
  res_mp@mpGridLineThicknessF  = 0.8
  res_mp@mpLimbLineThicknessF  = 0.8
  res_mp@mpNationalLineThicknessF  = 2.0
  res_mp@mpUSStateLineThicknessF  = 2.0
  
  res_mp@mpFillOn  = False  ; turn off map fill
  res_mp@tmXBLabelFont = "times-roman"
  res_mp@tmXBLabelFontHeightF = 0.016
  res_mp@tmYLLabelFont = "times-roman"
  res_mp@tmYLLabelFontHeightF = 0.016
  res_mp@pmTickMarkDisplayMode ="Always"

  res_mp@mpMinLatF=res@mpMinLatF
  res_mp@mpMaxLatF=res@mpMaxLatF
  res_mp@mpMinLonF=res@mpMinLonF
  res_mp@mpMaxLonF=res@mpMaxLonF
  


;;;;;;;;;;;;;;;plot rain  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  res_rain=True
  
  ; Set some map information ; line and text information
  res_rain@mpFillOn = True
 ; res_rain@mpFillColors  = (/"background","DeepSkyBlue","gray","DeepSkyBlue", "white"/)
  res_rain@mpGridAndLimbOn  = True
  res_rain@mpGeophysicalLineColor  = "Black"
;  res_rain@mpGeophysicalLineThicknessF = 0.5
  res_rain@mpGridLineColor  = "Black"
  res_rain@mpGridMaskMode  = "MaskNone"
  res_rain@mpGridSpacingF  = 5
  res_rain@mpLimbLineColor  = "Black"
  res_rain@mpLimbLineThicknessF  = 0.3
  res_rain@mpNationalLineColor  = "Black"  
;  res_rain@mpNationalLineThicknessF  = 0.5
  res_rain@mpPerimOn  = True
  res_rain@mpPerimLineColor  = "Black"
;  res_rain@mpUSStateLineColor  = "Black"
;  res_rain@mpUSStateLineThicknessF  = 0.5
  ;res_rain@mpGridSpacingF  = 45
  res_rain@pmTickMarkDisplayMode  = "Always"
 
  res_rain@gsnDraw  = False  ; don't draw
  res_rain@cnFillDrawOrder = "PreDraw"
  res_rain@gsnFrame  = False  ; don't advance frame
  res_rain@gsnMaximize  = False  ; maximize plot in frame
  res_rain@cnFillOn  = True
  res_rain@cnLinesOn  = False  ; turn off contour lines
  res_rain@cnLineLabelsOn  = False  ; turn off contour labels
  res_rain@cnInfoLabelOn  = False  ; turn off info label
  res_rain@lbBoxLinesOn  = False  ; turn off labelbar box lines
  ;res_rain@cnFillOpacityF  = 1.  ; .85 
  res_rain@cnFillMode  = "AreaFill"  ; for faster draw
  ;res_rain@cnFillColors = (/"White","green","blue","Green","Yellow","Red","Purple"/)
  

  
  

  gcmap = read_colormap_file("../../GFS_run/CMA_precipitation_official_platte_R1h.rgb")
  ;gcmap = read_colormap_file("./CMA_precipitation_official_platte.rgb")
  gcmapsize=dimsizes(gcmap)
  hcmap =new((/gcmapsize(0),4/),"float")
  
  hcmap=gcmap
  hcmap(:,3)=1.0

  
  res_rain@cnLevelSelectionMode = "ExplicitLevels"
  res_rain@cnLevels             = (/0.1,2.5, 5.0, 10.0, 25.0, 50.0,100/)
  res_rain@cnFillPalette         = hcmap
  res_rain@lbLabelBarOn= True           ; turn off contour labels
  res_rain@lbLabelsOn= True           ; turn off contour labels

  ;res_rain@cnFillOpacityF       = 1.               ; .85 

  
  
  ;res_rain@cnLevelSelectionMode = "ManualLevels"
  ;res_rain@cnMaxLevelValF  = 50  ;set maximum contour level  
  ;res_rain@cnMinLevelValF  =  5  ;set minimum contour level
  ;res_rain@cnLevelSpacingF  =  5 
    
  
  
  

  res_rain@pmLabelBarHeightF  = 0.085  ; Make labelbar less thick
  res_rain@pmLabelBarWidthF  = 0.5 ;值越小，越短
  res_rain@pmLabelBarOrthogonalPosF = 0.025
  res_rain@lbLabelFont = "times-roman"
  res_rain@lbLabelFontHeightF  = 0.015
  res_rain@lbTitleString = "precipitation(mm)"
  res_rain@lbTitleFontHeightF =0.015
  ;FontHeightF  = 0.016;

  res_rain@tiMainOffsetYF = 0.0 ;越大越往上
  res_rain@tiMainFont = "times-roman"
;  res_rain@tiMainFontHeightF = 0.024
;  res_rain@tiMainFontThicknessF = 0.19
  res_rain@gsnStringFont  = "times-roman"
;  res_rain@gsnLeftStringFontHeightF  = 0.016
;  res_rain@gsnRightStringFontHeightF  = 0.024
  res_rain@gsnLeftString   = ""
  res_rain@gsnRightString  = "" 

;;;;;;;;;;;;;;add label;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  resTx2= True
  resTx2@txFontHeightF = 0.015
  resTx2@txFontColor = "red"
  resTx3= True
  resTx3@txFontHeightF = 0.015
  resTx3@txFontColor = "blue"
  resTx4= True
  resTx4@txFontHeightF = 0.015
  resTx4@txFontColor = "deepskyblue"
  resTx5= True
  resTx5@txFontHeightF = 0.015
  resTx5@txFontColor = "blueviolet"
  
   ;====================read elev data====================
  offsetscater=2.7  
;  a =addfile("data.cdf","r")
;  ;print(a)
;  elev = a->elev
;  elev!0="lat"
;  elev!1="lon"
;  
;  print("elev read done")  
  
  rpres=True
  rpres@gsnDraw         = False
  rpres@gsnFrame        = False
  rpres@cnFillDrawOrder   = "Draw"
  rpres@cnFillOn   = True
  rpres@cnLinesOn  = False
  rpres@gsnFrame        = False  ; Make sure map fill happens
  rpres@tiMainString      = ""
  rpres@gsnCenterString   = ""
  rpres@gsnLeftString   = ""
  rpres@gsnRightString   = ""
  rpres@cnInfoLabelOn = False
  rpres@lbLabelBarOn = False
  rpres@cnLineLabelsOn = True
  rpres@cnLineLabelFontHeightF =0.01
  rpres@cnLevelSelectionMode = "ExplicitLevels"
  rpres@cnLevels = (/0.,500.,1000.,1500./)
  rpres@cnLineThicknessF = 6
  
  rpres@lbLabelBarOn = True
  rpres@lbTitleOn 									= True 					; 是否打开色标标题
  rpres@lbTitleString 							= "topography (m)" 				; 色标标题
  rpres@lbTitleFontHeightF        = 0.02  ; 色标标题高度  
  rpres@lbLabelFontHeightF        = 0.02
  rpres@pmLabelBarOrthogonalPosF 	= 0.20				; 色标垂直方向的位置  
  rpres@pmLabelBarParallelPosF 		= 0.5 				; 色标水平方向的位置
  rpres@pmLabelBarWidthF 					= 0.5 					; 色标的宽度
  rpres@pmLabelBarHeightF 				= 0.085 					; 色标的高度

  rpres@cnLineColor  = (/"grey4"/)
  cmap2 = read_colormap_file("MPL_Greys")  ; read color data
 ; cmap := cmap(25:,:)
  ;cmap(0,:) = (/0.,0.,0.,0/)
  rpres@cnFillPalette      = cmap2(:,:)  ; set color map
  
 month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
  "Oct","Nov","Dec"/)




  tstart_index = closest_val(thours0, timehours_start)
  tend_index = closest_val(thours1, timehours_end)
  
  dir ="./"
  ;dir =""
  ;ftype="x11"
  ftype="png"

  outstring0=cd_string(timehours_start(tstart_index),format)
  outstring1=cd_string(timehours_end(tend_index),format)

  pltName = "GPM_IMERG_R1n_"+ outstring0+"_"+outstring1+"UTC_WRF_Domain"
  wks = gsn_open_wks(ftype,dir + pltName)  
  




  res_rain@gsnLeftString  = "GPM IMERG " + outstring0+"_"+outstring1
  ;res_rain@gsnLeftStringOrthogonalPosF  = 0.05
do n = tstart_index, tend_index
  f:=addfile(files(n),"r")
  ;printMinMax(f->/Grid/precipitation,0)
  ;print(dimsizes(transpose(f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF} ))))
  rain(:,:)  = transpose(f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF} ))
  ;print(sizeof(rain_sum))
  rain_sum = rain_sum+rain*0.5
  
  ;printMinMax(rain_sum,0)

  max_rain = max(rain_sum)
  ;print(max_rain)
  
  ; Flatten the 2D rain array using ndtooned
rain_flat = ndtooned(rain_sum)

; Find the index of the maximum rainfall value in the flattened array
maxloc_flat = ind(rain_flat.eq.max_rain)

; Convert the flat index to the original 2D array indices
maxloc = ind_resolve(maxloc_flat, dimsizes(rain_sum))

;print(maxloc)
; Get latitude and longitude coordinates of the maximum rainfall
lat_max = ori&lat(maxloc(0,0))   ; Latitude at max rain
lon_max = ori&lon(maxloc(0,1))   ; Longitude at max rain


  ;print(lat_max)
  ;print(lon_max)
  ;print(rain({lon|lon_max},{lat|lat_max})/2.)
  ;exit
;  printVarSummary(ori)

;  exit
  ;rain@long_name = "precipitationCal"
  ;rain@units = f->precipitationCal@units
  ;rain@_FillValue = f->precipitationCal@_FillValue
  
	
  utc_date  = cd_calendar(f->time,0)
  year  = tointeger(utc_date(:,0))  ; Convert to integer for
  month  = tointeger(utc_date(:,1))  ; use sprinti 
  day  = tointeger(utc_date(:,2))
  hour  = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
 ;
 ; Write out strings in the format "hhZ dd mmm yyyy".
 ;

  date_str = sprinti("%0.2iZ ", hour) + sprinti("%0.2i ", day) + \
  month_abbr(month) + " "  + sprinti("%0.4i", year)
  
  
  ;;;;;;;;;;special attr for string ;;;;;;;;;;
  
  ;res_rain@gsnRightString  = "forecast "+ hour_str +"hr"
  ;res_rain@gsnCenterString  = "500hPa"
  res_rain@gsnStringFontHeightF  = 0.022
  res_rain@gsnLeftStringOrthogonalPosF  = 0.03
  res_rain@gsnRightStringOrthogonalPosF = 0.03
  res_rain@gsnCenterStringOrthogonalPosF = 0.03
  res_rain@cnLineThicknessF  = 4.0
  ; res_rain@gsnCenterString  = "ECMWF"
  ;res_rain@gsnCenterStringFontHeightF  = 0.05
  ;res_rain@gsnCenterStringOrthogonalPosF = 0.03

  res                     = True          ; plot mods desired
  res@cnFillOn            = True          ; turn on color
  res@cnFillPalette       = "WhiteBlueGreenYellowRed" ; set color map 
  res@vpWidthF            = 0.5           ; change aspect ratio of plot
  res@vpHeightF           = 0.3
  res@gsnMaximize         = True          ; maximize plot size
  
  
  ;gsn_define_colormap(wks,"wind_17lev") 
  ;gsn_define_colormap(wks,"BlGrYeOrReVi200")

  

 end do


 copy_VarCoords(rain, rain_sum)
;; Define the output NetCDF file name
;out_file = "GPM_accumulated_rain_stage3.nc"
;aa=systemfunc("rm "+out_file)
;; Create a new NetCDF file (NetCDF4 format)
;ncid = addfile(out_file, "c")
;printVarSummary(rain)
;printVarSummary(rain_sum)
;ncid->rain_sum = rain_sum   ; 'var' is the name of the variable inside the NetCDF file
;
;; Optionally, add attributes to the variable
;ncid->rain_sum@long_name := "accumulated_rain"+outstring0+"_"+outstring1
;ncid->rain_sum@units := "mm"

 
;  ;====================read precipitation data====================
;  file_path="Doksuri_rain_0726-30_China_4stages.txt"
;  data  = asciiread(file_path,-1,"string") 
;  istage=3
;  ;nfields = str_fields_count(data(1)," ")
;  ;print("number of fields = " + nfields)
;  sta1 = str_get_field(data(::), 1," ")
;  lon1 = stringtofloat(str_get_field(data(::), 3," "))
;  lat1 = stringtofloat(str_get_field(data(::), 2," "))      
;  R = stringtofloat(str_get_field(data(::), 4+istage," "))    
;  R@_FillValue=9999   
;  R@lat1d=lat1
;  R@lon1d=lon1
;  nlines=dimsizes(lon1)
;
;  mpres              = True
;  mpres@cnInfoLabelOn = False  
;  mpres@cnLineLabelsOn = True
;  mpres@cnLineLabelFontHeightF =0.012
;  mpres@tmXTOn =False
;  mpres@tmYROn =False
;  mpres@gsnMaximize  = True             ; Maximize plot in frame.
;  mpres@gsnFrame     = False            ; Don't advance the frame
;  mpres@gsnDraw      = False            ; Don't advance the frame
;  arr=(/200./)
;  mpres@cnLevels          = arr
;  num_distinct_markers = dimsizes(arr)+1        ; number of distinct markers                                       ; bin1 = 0.:4.999, etc.)
;  narr = dimsizes(arr)   
;  mpres@cnFillOn = False
;  mpres@cnLinesOn = True
;  mpres@cnLineColor = "grey4"
;  mpres@cnLineThicknessF = 5.
;   
;  map1 = gsn_csm_contour(wks,R,mpres) 


 ; map2 = gsn_csm_contour(wks,elev({res@mpMinLatF:res@mpMaxLatF},{res@mpMinLonF:res@mpMaxLonF}),rpres) 

  contour_z  = gsn_csm_contour(wks,rain_sum,res_rain)   
  map  = gsn_csm_map(wks,res_mp)


 ; china_river(wks, map,"chocolate4",4.0,0)
 ; china_map(wks, map,"chocolate4",2.5,0)



  ;overlay(map,map2)
  overlay(map,contour_z)

  ;gsn_text_ndc(wks,"Preciptation (mm) ",0.5,0.16,resTx2)
  draw(map)
  frame(wks)
  delete(map)
  delete(wks)

 end