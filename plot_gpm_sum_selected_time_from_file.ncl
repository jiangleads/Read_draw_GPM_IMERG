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
 ; print(nl)
  grib  = addfile(path+"3B-HHR.MS.MRG.3IMERG.20230725-S040000-E042959.0240.V07B.HDF5", "r")
  
  ;ori  = grib->precipitationCal(:,{115:121},{23:29})
  ori  = grib->/Grid/precipitation (:,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF})
  dims  = dimsizes(ori)
  nhours  = dims(0)
  mlon  = dims(1)
  nlat  = dims(2)
	
	print(dims)
  
  rain  = new((/mlon,nlat/),"float") 
  rain_sum  = new((/mlon,nlat/),"float") 
  rain_sum = 0
  ;print(files)
  ;exit
  T0=214
  T1=249
  ;printVarSummary(rain)
  print(files(T0))
  print(files(T1))
  do n=T0,T1
   f:=addfile(files(n),"r")
   ;printVarSummary(f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF} ))
   rain(:,:)  = f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF} )
   ;print(sizeof(rain_sum))
   rain_sum = rain_sum+rain
  end do
  copy_VarCoords(f->/Grid/precipitation(0,{res@mpMinLonF:res@mpMaxLonF},{res@mpMinLatF:res@mpMaxLatF}),rain_sum)
  ;printVarSummary(rain_sum)
 ; printMinMax(rain_sum,0)
  print("START")
  ncid=addfile("/unsa/lzjiang/sum_prcp_gpm_IMERG_072812-072906.nc","c")
  print("START11")
  ncid->rain_sum = rain_sum(lat|:,lon|:) 
  
  
;print(rain_sum&lat)
; Write the coordinate variables
;ncid->lat = rain_sum&lat
;ncid->lon = rain_sum&lon

printVarSummary(ncid->rain_sum)
printMinMax(ncid->rain_sum,0)
  exit
   
  
 end




