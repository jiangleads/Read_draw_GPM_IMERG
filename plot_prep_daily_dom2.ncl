; this scripts was created by Lizhi Jiang , jianglizhi@mail.iap.ac.cn 22,Apr,2020
;   Script display location of model domains
;   Only works for ARW domains
;   Reads namelist file directly
;   ------------------------------------------------------------
;   ncl版本应低于6.6
;   输入数据"data.cdf" 位于 174行附近
;   地形色标设置，见236-240行附近
;   地形高度的等值线间隔设置，见 246行-253行附近
;   ------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

domain_id_of_map=2
; Check the version of NCL
  newversion= False
  version = systemfunc("ncl -V")
  if(version.gt.6.6) then
    print("version should no higher than NCL V6.6.0")
    newversion= True
  end if
  
; We generate plots, but what kind do we prefer?
;  type = "x11"
  type = "pdf"
; type = "ps"
;type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"gpm_prep_dom2")

; read the following namelist file
  filename = "/home/jlz/2018nov/wps/namelist.wps"

                   
; Set the colors to be used
  colors = (/"white","black","White","ForestGreen","transparent","Red","Blue"/)
  gsn_define_colormap(wks, colors)  


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
  opts@mpOutlineDrawOrder  		= "preDraw"		; 设置地图轮廓绘图顺序
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
  
   opts@gsnMaximize        = True     ; maximize plot in frame
;   cmap = read_colormap_file("OceanLakeLandSnow")  ; read color data
;   opts@cnFillOn           = True     ; turn on contour fill
;   opts@cnFillPalette      = cmap(1:,:)  ; set color map
   opts@cnLinesOn          = False    ; turn off contour lines
   opts@cnLineLabelsOn     = False    ; turn off line labels
   opts@cnInfoLabelOn      = False    ; turn off info label
   opts@lbBoxLinesOn       = False    ; turn off labelbar box lines
  
   opts@cnFillMode         = "RasterFill"   ; for faster draw
    
    
    
  
  ;warning!!!!!!!!!!!!!!!  
    
    
    numOffSetPoints = 0
    if ( mpres@max_dom .gt. 1 ) then

    if ( isatt(txres,"domOffSet") ) then
       numOffSetPoints = 0
       numOffSetPoints = dimsizes(txres@domOffSet)
    end if
    if ( isatt(lnres,"domLineColors") ) then
       numLineColors = 0
       numLineColors = dimsizes(lnres@domLineColors)
    end if
    
       
    
    do idom = 1,mpres@max_dom-1

      OffSetPoint = 0
      if ( numOffSetPoints .gt. 0 ) then
        if ( numOffSetPoints .ge. idom ) then
          OffSetPoint = txres@domOffSet(idom-1)
        end if
      end if
      if ( numLineColors .gt. 0 ) then
        if ( numLineColors .ge. idom ) then
          lnres@gsLineColor = lnres@domLineColors(idom-1)
          txres@txFontColor = lnres@domLineColors(idom-1)
        else
          lnres@gsLineColor = lnres@domLineColors(numLineColors-1)
          txres@txFontColor = lnres@domLineColors(numLineColors-1)
        end if
      end if

      ; nest start and end points in large domain space
      if ( mpres@parent_id(idom) .eq. 1) then
        ; corner value
        i_start = mpres@i_parent_start(idom)
        j_start = mpres@j_parent_start(idom)
        ; end point
        i_end = (mpres@e_we(idom)-1)/mpres@parent_grid_ratio(idom) + i_start
        j_end = (mpres@e_sn(idom)-1)/mpres@parent_grid_ratio(idom) + j_start
      end if
      if ( mpres@parent_id(idom) .ge. 2) then
        ; corner value
        nd = mpres@parent_id(idom)
        i_points = ((mpres@e_we(idom)-1)/mpres@parent_grid_ratio(idom))
        j_points = ((mpres@e_sn(idom)-1)/mpres@parent_grid_ratio(idom))
        ai_start = mpres@i_parent_start(idom)*1.0
        aj_start = mpres@j_parent_start(idom)*1.0
        do while ( nd .gt. 1)
          ai_start = ai_start/mpres@parent_grid_ratio(nd-1) + mpres@i_parent_start(nd-1)
          aj_start = aj_start/mpres@parent_grid_ratio(nd-1) + mpres@j_parent_start(nd-1)
          i_points = (i_points/mpres@parent_grid_ratio(nd-1))
          j_points = (j_points/mpres@parent_grid_ratio(nd-1))
          nd = nd - 1
        end do
        i_start = tointeger(ai_start + .5 )
        j_start = tointeger(aj_start + .5 )
        ; end point
        i_end = i_points + i_start + 1
        j_end = j_points + j_start + 1
      end if
      xx = int2flt(i_start)
      yy = int2flt(j_start)
      loc = wrf_ij_to_ll (xx,yy,opts)
      cor_lon = loc(0)
      cor_lat = loc(1)

      delete(start_lat)
      delete(start_lon)
      start_lat = cor_lat
      start_lon = cor_lon
       
      opts@start_lat   = start_lat
      opts@start_lon   = start_lon
      print("ln337:")
      print("lat0:"+ start_lat )
      print("lon0:"+ start_lon  )
      
      xx2 = int2flt(i_end)
      yy2 = int2flt(j_end)
      loc2 = wrf_ij_to_ll (xx2,yy2,opts)
      print("Ln347:")
      
      opts@end_lon = loc2(0)
      opts@end_lat = loc2(1)

      print("latn:"+ opts@end_lat )
      print("lonn:"+ opts@end_lon  )
      
      


      start_lat = cor_lat
      start_lon = cor_lon

 
 
    end do
    
    
    end if
    
  ;warning!!!!!!!!!!!!!!!  

   
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
  opts@mpFillOn = True
  opts@mpFillColors  = (/"background","DeepSkyBlue","gray","DeepSkyBlue", "transparent"/)

  opts@mpGridAndLimbOn             = True
  opts@mpGeophysicalLineColor      = "Black"
;  opts@mpGeophysicalLineThicknessF = 0.5
  opts@mpGridLineColor             = "Black"
  opts@mpGridMaskMode              = "MaskNone"
  opts@mpGridSpacingF              = 5
  opts@mpLimbLineColor             = "Black"
  opts@mpLimbLineThicknessF        = 0.3
  opts@mpNationalLineColor         = "Black"  
;  opts@mpNationalLineThicknessF    = 0.5
  opts@mpPerimOn                   = True
  opts@mpPerimLineColor            = "Black"
;  opts@mpUSStateLineColor          = "Black"
;  opts@mpUSStateLineThicknessF     = 0.5
  ;opts@mpGridSpacingF              = 45
  opts@gsnLeftString 					     = ""
  opts@gsnRightString 					     = ""
  opts@pmTickMarkDisplayMode       = "Always"
 
  ;rain
  cmap     := read_colormap_file("WhiteBlueGreenYellowRed")
  cmap(0,:) = (/0,0,0,0/)
   
   ;---Set resources for rain plot
  res_tot                      = opts
  res_tot@cnFillOn             = True
  res_tot@cnFillMode           = "RasterFill"
  res_tot@cnLinesOn            = False            ; turn off contour lines
  res_tot@cnLineLabelsOn       = False            ; turn off contour labels
  res_tot@cnFillOpacityF       = 1.               ; .85 
  res_tot@cnLevelSelectionMode = "ExplicitLevels"
  res_tot@cnLevels             = (/10,20,30,50,75,100,150,200/)
;  res_tot@cnLevels             = (/0.1,1,2,4,6,8,10,20,50/)
  res_tot@cnFillPalette         = cmap
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
  res_tot@gsnRightString       = "unit:mm" 
 ;res_tot@gsnLeftString        =  "station data(line)"
  ;res_tot@gsnLeftString  = "era5 data(shade)"
  ;res@gsnRightString = ""
;plot=new(numFILES,graphic) 
  ;do ihour = 0,numFILES-2     ;numFILES-2   ; 0, dims(0)-2
  	

	
;; draw terrain?  
   a = addfile("gpm.201811.nc","r") 
 ;  a = addfile("data.cdf","r") 


    utc_date = cd_calendar(a->time, 0)
 ;
 ; Store return information into more meaningful variables.
 ;
   year   = tointeger(utc_date(:,0))    ; Convert to integer for
   month  = tointeger(utc_date(:,1))    ; use sprinti 
   day    = tointeger(utc_date(:,2))
   hour   = tointeger(utc_date(:,3))
   minute = tointeger(utc_date(:,4))
   second = tointeger(utc_date(:,5))
   month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                    "Oct","Nov","Dec"/)
   date_str = sprinti("%0.4i", year) +"-"+sprinti("%0.2i", month)+"-" \
   + sprinti("%0.2i", day) +"_" +sprinti("%0.2i", hour)+":"+sprinti("%0.2i", minute)+":"+sprinti("%0.2i", second)+"UTC"
          
   
   lon=a->lon
   lat=a->lat

   rain = a->prep
;   rain!0 = "time"
;   rain!1 = "lat"
;   rain!2 = "lon"
;   rain&time=time
;   rain&lon=lon
;   rain&lat=lat
  
      
   dims=dimsizes(rain)                            ; get dimensions
   ntime=dims(0)
   nlon=dims(1)                                ; assign # lat/lon points
   nlat=dims(2)
   
do j=0,ntime-49,48
 
   wks = gsn_open_wks(type,"gpm_prep."+date_str(j+48))    
  
   if(j.le.ntime-1) then  
     rain24h=(dim_sum_n_Wrap(rain(j+1:j+47,:,:),0))*0.5+(rain(j,:,:)+rain(j+48,:,:))*0.25
     print(dimsizes(rain24h))
     rain24h!0 = "lat"
     rain24h!1 = "lon"
;     rain&time=time
     rain24h&lon=lon
     rain24h&lat=lat
	 end if

	
   res_tot@tiMainString                   ="gpm.    "+date_str(j+48)+" rain"
   
   ;print(opts)
   mp = gsn_csm_contour_map(wks,rain24h,res_tot)

  
  
   frame(wks)           ; lets frame the plot - do not delete
end do
end
