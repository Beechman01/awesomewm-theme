--[
--
--    Testing lua in conky
--
--
--]
require 'cairo'




local scale = 2

--[[font variables]]
local fontSlant = CAIRO_FONT_SLANT_NORMAL
local fontFace  = CAIRO_FONT_WEIGHT_NORMAL
local header    = 14 * scale
local fontSize  = 12 * scale
local font      = "Roboto"
local clockFont = "DSEG7 Classic Mini"   --"DS-Digital"
local dateFont  = "Silent Reaction"
local clockWeight = CAIRO_FONT_WEIGHT_BOLD
local clockSize = 26 * scale
local dateSize  = 12 * scale

local blue      = {}
  blue.r        = 133/255
  blue.g        = 172/255
  blue.b        = 251/255

local purple    = {}
  purple.r      = 156/255
  purple.g      = 100/255
  purple.b      = 177/255

--local imPath = "/home/beechman/.config/conky/neon-conky/lua/images/"

--[[system variables]]
local user   = conky_parse("${USER}")
local wm     = conky_parse("${DESKTOP_SESSION}")
local kernel = conky_parse("${execi 60000 uname -r}")




function createText(xpos, ypos, font, font_size, r, g, b, a, font_slant, font_face, data)

  r = r
  g = g
  b = b

  cairo_select_font_face(cr,font,font_slant,font_face)
  cairo_set_font_size (cr,font_size)
  cairo_set_source_rgba (cr,r,g,b,a)
  cairo_move_to (cr,xpos,ypos)
  cairo_show_text(cr,data)
  cairo_stroke(cr)

end

function blink()

  if (os.date("%S") % 2 == 0) then
    return 1
  else
    return 0
  end


end


function clock()

  local time       = os.date("%H:%M:%S")
  local timeLength = string.len(time)
  local date       = os.date("%A %B %d, %Y")
  local dateLength = string.len(tostring(date))
  local dateCentre = (conky_window.width/6.5)
  local timeCentre = (conky_window.width/5.5)

  createText(timeCentre,80, clockFont,clockSize,blue.r,blue.g,blue.b,0.1,fontSlant,clockWeight,"00:00:00")
  createText(timeCentre,80, clockFont,clockSize,blue.r,blue.g,blue.b,1,fontSlant,clockWeight,os.date("%H %M %S"))
  createText(timeCentre,80, clockFont,clockSize,blue.r,blue.g,blue.b,blink(),fontSlant,clockWeight,"!!:!!:!!")
  createText(dateCentre,110,dateFont,dateSize,purple.r,purple.g,purple.b,1,fontSlant,fontFace,date)

end

function epochDay()

  local secInDay = (60*60)*24
  local yr = os.date("%Y")

  local startDate = os.time({year = yr, month = 1, day = 1})
  local curDate = os.time({year = os.date("%Y"),month = os.date("%m"),day = os.date("%d")})
  local dateDiff = math.ceil(os.difftime(startDate,curDate)/secInDay)
  local invertDateDiff = math.abs(tonumber(dateDiff))*1

  return invertDateDiff

end

function epochMonth()

  local secInMonth = ((60*60)*24)*30
  local yr = os.date("%Y")
  local m = os.date("%m")

  local startDate = os.time({year = yr, month = 1, day = 1})
  local curDate = os.time({year = os.date("%Y"), month = os.date("%m"), day = os.date("%d")})
  local dateDiff = math.ceil(os.difftime(startDate,curDate)/secInMonth)
  local invertDateDiff = math.abs(tonumber(dateDiff))

  return invertDateDiff

end

function clockLines()

  local w = 4
  local cap = CAIRO_LINE_CAP_ROUND
  local x = 40
  local y = 130
  local endx = 365

  local time = {(endx/365)*epochDay(),(endx/24)*os.date("%H"),(endx/60)*os.date("%M"),(endx/60)*os.date("%S")}

  cairo_set_line_width(cr,w)
  cairo_set_line_cap(cr,cap)

-- Draws background
  cairo_set_source_rgba(cr,purple.r,purple.g,purple.b,1)
  for bg = 0,3 do
    cairo_move_to(cr,x,y+(bg*10))
    cairo_rel_line_to(cr,endx,0)
  end
  cairo_stroke(cr)

-- Draws time lines

  cairo_set_source_rgba(cr,blue.r,blue.g,blue.b,1)
  for timeL = 0,3 do
    cairo_move_to(cr,x,y+(timeL*10))
    cairo_rel_line_to(cr,time[timeL+1],0)
  end
  cairo_stroke(cr)

end

function memBar(x,y)

  local w = 390
  local h = 25
  local lw = 3

  local cMemMax = tostring(conky_parse("${memmax}"))
  local cMemCur = tostring(conky_parse("${mem}"))

  local sMemMax = string.gsub(cMemMax, 'G', '')

  if string.find(cMemCur, 'G') then
    sMemCur = string.gsub(cMemCur, 'G', '')
  elseif string.find(cMemCur,'M') then
    sMemCur = string.gsub(cMemCur, 'M','')
  end

  local memMax = tonumber(sMemMax)
  local memCur = tonumber(sMemCur)

  if memCur > 31 then
    memCur = tonumber(sMemCur)/1000
  else
    memCur = tonumber(sMemCur)
  end

  local value = (w/memMax)*memCur


-- Draws data bar
  cairo_set_line_width(cr,2)
  cairo_set_source_rgba(cr,blue.r,blue.g,blue.b,1)
  cairo_rectangle(cr,x,y,value,h)
  cairo_fill_preserve(cr)
  cairo_fill(cr)

-- Draws border
  cairo_set_line_width(cr,lw)
  --cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
  cairo_rectangle(cr,x,y,w,h)
  cairo_set_source_rgba(cr,0,0,0,0)
  cairo_fill_preserve(cr)
  cairo_set_source_rgba(cr,purple.r,purple.g,purple.b,1)
  --cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
  cairo_stroke(cr)

end

function cpuBar(x,y,cpu)

  w      = 17
  h      = 70
  maxValue = 100
  scale  = h/maxValue
  barH   = scale*cpu

  -- Draws bar background
  --cairo_set_source_rgba(cr,164/255,44/255,214/255,1)
  --cairo_rectangle(cr,x,y,w,h)
  --cairo_fill(cr)

  -- Draws cpu bar
  cairo_set_source_rgba(cr,blue.r,blue.g,blue.b,1)
  cairo_rectangle(cr,x,y+h,w,-barH)
  cairo_fill(cr)

  -- Test border
  cairo_set_line_width(cr,2)
  cairo_rectangle(cr,x,y,w,h)
  --cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
  cairo_set_source_rgba(cr,0,0,0,0)
  cairo_fill_preserve(cr)
  cairo_set_source_rgba(cr,purple.r,purple.g,purple.b,1)
  cairo_stroke(cr)
end

function cpuBarDisplay(y)

  local x = 40
  local cpus = {tonumber(conky_parse("${cpu cpu1}")),
                tonumber(conky_parse("${cpu cpu2}")),
                tonumber(conky_parse("${cpu cpu3}")),
                tonumber(conky_parse("${cpu cpu4}")),
                tonumber(conky_parse("${cpu cpu5}")),
                tonumber(conky_parse("${cpu cpu6}")),
                tonumber(conky_parse("${cpu cpu7}")),
                tonumber(conky_parse("${cpu cpu8}")),
                tonumber(conky_parse("${cpu cpu9}")),
                tonumber(conky_parse("${cpu cpu10}")),
                tonumber(conky_parse("${cpu cpu11}")),
                tonumber(conky_parse("${cpu cpu12}")),
                tonumber(conky_parse("${cpu cpu13}")),
                tonumber(conky_parse("${cpu cpu14}")),
                tonumber(conky_parse("${cpu cpu15}")),
                tonumber(conky_parse("${cpu cpu16}")),
                tonumber(conky_parse("${cpu cpu17}")),
                tonumber(conky_parse("${cpu cpu18}")),
                tonumber(conky_parse("${cpu cpu19}")),
                tonumber(conky_parse("${cpu cpu20}")),
                tonumber(conky_parse("${cpu cpu21}")),
                tonumber(conky_parse("${cpu cpu22}")),
                tonumber(conky_parse("${cpu cpu23}")),
                tonumber(conky_parse("${cpu cpu24}"))
                }

  for i = 1, 12 do
    cpuBar(i*33,y,cpus[i])
  end

  for j = 13, 24 do
    cpuBar((j-12)*33,y+90,cpus[j])
  end

end

local function gpuUsageArc()

  cairo_set_source_rgba(cr,220/255,218/255,213/255,1)
  cairo_set_line_width(rc,10)
  arc(cr,390,100,90,-90 * (math.pi/180),45 * (math.pi/180))
  cairo_stroke(cr)

end

function conky_main()


  if conky_window == nil then return end

  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
        cr = cairo_create(cs)
  updates=tonumber(conky_parse('${updates}'))





      if updates>5 then
--##############################
        --print ("Number of updates = ",updates)
        --print(os.date())
--##############################


        clock()
        clockLines()
        cpuBarDisplay(470)
        memBar(30,680)

--        gpuUsageArc()

      end-- if updates>5



cairo_destroy(cr)
cairo_surface_destroy(cs)
cr=nil
end -- end main function
