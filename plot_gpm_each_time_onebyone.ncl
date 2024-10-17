;load "/mnt/e/Doksuri/scripts/cn/ufunc01.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  
  ;;;;;;;;;;;read data;;;;;;;;

  path = "/unsa/lzjiang/OSCER_bak/lzjiang/data/GPM_IMERG/"
  files = systemfunc("ls "+path+"*2023*.HDF5")
	
  res=True
  
  res@mpMinLatF=10
  res@mpMaxLatF=35
  res@mpMinLonF=108
  res@mpMaxLonF=138
  
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

  res_mp = True
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
  res_rain@gsnFrame  = False  ; don't advance frame
  res_rain@gsnMaximize  = True  ; maximize plot in frame
  res_rain@cnFillOn  = True
  res_rain@cnLinesOn  = False  ; turn off contour lines
  res_rain@cnLineLabelsOn  = False  ; turn off contour labels
  res_rain@cnInfoLabelOn  = False  ; turn off info label
  res_rain@lbBoxLinesOn  = False  ; turn off labelbar box lines
  ;res_rain@cnFillOpacityF  = 1.  ; .85 
  res_rain@cnFillMode  = "RasterFill"  ; for faster draw
  ;res_rain@cnFillColors = (/"White","green","blue","Green","Yellow","Red","Purple"/)
  
  ;res_rain@cnLevelSelectionMode = "ExplicitLevels"
  ;res_rain@cnLevels  = (/0.1,10,20,30,50,75,100,150,200/)
  ;res_rain@cnLevels  = (/0.1,1,2,4,6,8,10,20,50/)
  cmap  := read_colormap_file("WhiteBlueGreenYellowRed")
  ;cmap = read_colormap_file("OceanLakeLandSnow")  ; read color data
  cmap(0,:) = (/0,0,0,0/)
  ;res_rain@cnFillPalette  = cmap(1:,:)  ; set color map
  res_rain@cnFillPalette  = cmap
  ;res_rain@cnLevelSelectionMode = "ManualLevels"
  ;res_rain@cnMaxLevelValF  = 50  ;set maximum contour level  
  ;res_rain@cnMinLevelValF  =  5  ;set minimum contour level
  ;res_rain@cnLevelSpacingF  =  5 
    
  
  
  

  res_rain@pmLabelBarHeightF  = 0.085  ; Make labelbar less thick
  res_rain@pmLabelBarWidthF  = 0.5 ;值越小，越短
  res_rain@pmLabelBarOrthogonalPosF = 0.025
  res_rain@lbLabelFont = "times-roman"
  res_rain@lbLabelBarOn  = True
  res_rain@lbLabelFontHeightF  = 0.02
  res_rain@lbTitleString = "precipitation(mm)"
  res_rain@lbTitleFontHeightF =0.02
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
  a =addfile("data.cdf","r")
  ;print(a)
  elev = a->elev
  elev!0="lat"
  elev!1="lon"
  
  print("elev read done")  
  
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

do n = 0, nl-1
  f:=addfile(files(n),"r")
  printMinMax(f->/Grid/precipitation,0)
  rain(:,:)  = transpose(f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF} ))
  ;print(sizeof(rain_sum))
  rain_sum = rain_sum+rain
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
  res_rain@gsnLeftString  = "GPM IMERG " + date_str
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
  
  dir ="./"
  ;dir =""
  ftype="x11"
  ;ftype="png"
  pltName = "BIG_FUJIAN_GPM_Preicp"+ date_str
  wks = gsn_open_wks(ftype,dir + pltName)  
  ;gsn_define_colormap(wks,"wind_17lev") 
  ;gsn_define_colormap(wks,"BlGrYeOrReVi200")

  
  res_mp@mpMinLatF=10
  res_mp@mpMaxLatF=35
  res_mp@mpMinLonF=108
  res_mp@mpMaxLonF=138
  
  
  map2 = gsn_csm_contour(wks,elev({res@mpMinLatF:res@mpMaxLatF},{res@mpMinLonF:res@mpMaxLonF}),rpres) 
  contour_z  = gsn_csm_contour(wks,rain,res_rain)   
  map  = gsn_csm_map(wks,res_mp)
 ; china_river(wks, map,"chocolate4",4.0,0)
;  china_map(wks, map,"chocolate4",2.5,0)
  overlay(map,map2)
  overlay(map,contour_z)
  ;gsn_text_ndc(wks,"Preciptation (mm) ",0.5,0.16,resTx2)
  draw(map)
  frame(wks)
  delete(map)
  delete(wks)

 end do


 end




