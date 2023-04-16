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

--[[system variables]]
local user   = conky_parse("${USER}")
local wm     = conky_parse("DESKTOP_SESSION")
local kernel = conky_parse("${exec uname -r}")




function createText(xpos, ypos, font, font_size, r, g, b, a, font_slant, font_face, data)

  r = r/255
  g = g/255
  b = b/255

  cairo_select_font_face(cr,font,font_slant,font_face)
  cairo_set_font_size (cr,font_size)
  cairo_set_source_rgba (cr,r,g,b,a)
  cairo_move_to (cr,xpos,ypos)
  cairo_show_text(cr,data)
  cairo_stroke(cr)

end

function clock()

  local time       = os.date("%H:%M:%S")
  local timeLength = string.len(time)
  local date       = os.date("%A %B %d, %Y")
  local dateLength = string.len(date)
  local dateCentre = (conky_window.width/10)
  local timeCentre = (conky_window.width/7)

  createText(timeCentre,80, clockFont,clockSize,25,229,255,1,fontSlant,clockWeight,os.date("%H:%M:%S"))
  createText(dateCentre,110,dateFont,dateSize,164,44,214,1,fontSlant,fontFace,date)

end


function clockLines()

  local w = 4
  local cap = CAIRO_LINE_CAP_ROUND
  local x = 30
  local y = 125
  local endx = 340

  local time = {(endx/24)*os.date("%H"),(endx/60)*os.date("%M"),(endx/60)*os.date("%S")}

  cairo_set_line_width(cr,w)
  cairo_set_line_cap(cr,cap)

-- Draws background
  cairo_set_source_rgba(cr,164/255,44/255,214/255,1)
  for bg = 0,2 do
    cairo_move_to(cr,x,y+(bg*10))
    cairo_rel_line_to(cr,endx,0)
  end
  cairo_stroke(cr)

-- Draws time lines
  cairo_set_source_rgba(cr,25/255,229/255,214/255,1)
  for timeL = 0,2 do
    cairo_move_to(cr,x,y+(timeL*10))
    cairo_rel_line_to(cr,time[timeL+1],0)
  end
  cairo_stroke(cr)

end

function memBar(x,y)

  local w = 360
  local h = 25
  local lw = 3

  local cMemMax = tostring(conky_parse("${memmax}"))
  local cMemCur = tostring(conky_parse("${mem}"))

  local sMemMax = string.gsub(cMemMax, 'G', '')
  local sMemCur = string.gsub(cMemCur, 'G', '')

  local memMax = tonumber(sMemMax)
  local memCur = tonumber(sMemCur)


  local value = (w/memMax)*memCur


-- Draws data bar
  cairo_set_line_width(cr,2)
  cairo_set_source_rgba(cr,25/255,229/255,255/255,1)
  cairo_rectangle(cr,x,y,value,h)
  cairo_fill_preserve(cr)
  cairo_fill(cr)

-- Draws border
  cairo_set_line_width(cr,lw)
  cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
  cairo_rectangle(cr,x,y,w,h)
  cairo_set_source_rgba(cr,0,0,0,0)
  cairo_fill_preserve(cr)
  cairo_set_source_rgba(cr,164/255,44/255,214/255,1)
  cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
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
  cairo_set_source_rgba(cr,25/255,229/255,255/255,1)
  cairo_rectangle(cr,x,y+h,w,-barH)
  cairo_fill(cr)

  -- Test border
  cairo_set_line_width(cr,2)
  cairo_rectangle(cr,x,y,w,h)
  cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
  cairo_set_source_rgba(cr,0,0,0,0)
  cairo_fill_preserve(cr)
  cairo_set_source_rgba(cr,164/255,44/255,214/255,1)
  cairo_stroke(cr)
end

function cpuBarDisplay(y)

  local x = 20
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
    cpuBar(i*30,y,cpus[i])
  end

  for j = 13, 24 do
    cpuBar((j-12)*30,y+90,cpus[j])
  end

end



function conky_main()

  --createText(100,50,font,12,0.5,0.5,1,1,font_slant,font_face,text[1])

  local cpu1 = tonumber(conky_parse("${cpu cpu1}"))
  local cpu2 = tonumber(conky_parse("${cpu cpu2}"))



  if conky_window == nil then return end

  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
        cr = cairo_create(cs)
  updates=tonumber(conky_parse('${updates}'))

      if updates>5 then
--##############################
        print ("Number of updates = ",updates)
        print(os.date())
--##############################
        print("${exec nvidia-smi -q}")

        clock()
        clockLines()
        --cpuBar(20,520,cpu1)
        --cpuBar(40,520,cpu2)
        cpuBarDisplay(540)
        memBar(20,820)



      end-- if updates>5

      --createText(100,100,"Roboto",fontSize,52,229,255,1,fontSlant,fontFace,os.date("%A"))
      --createText(100,130,"Roboto",fontSize,52,229,255,1,fontSlant,fontFace,"CORES: ")

cairo_destroy(cr)
cairo_surface_destroy(cs)
cr=nil
end -- end main function
