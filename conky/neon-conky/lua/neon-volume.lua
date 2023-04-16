--[
--
--    Testing lua in conky
--
--
--]
require 'cairo'




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

function volume()

  local getVolInfo = conky_parse( "${exec amixer get Master | grep Left: | awk '{print $5}' }" )
  local volFilter  = string.gsub(getVolInfo, '[%c%p%s]','')
  local vol        = tonumber(volFilter)

  local w = 9
  local cap = CAIRO_LINE_CAP_ROUND
  local xpos = conky_window.width / 2
  local ypos = 105
  local endx = 0
  local endy = -90

  local volpos = math.abs(vol*5)*-1

  print(volpos)

-- set width & cap
  cairo_set_line_width(cr,w)
  cairo_set_line_cap(cr,cap)

-- Draws background
  cairo_set_source_rgba(cr,164/255,44/255,214/255,1)
  cairo_move_to(cr,xpos,ypos)
  cairo_rel_line_to(cr,endx,endy)

  cairo_stroke(cr)

-- Draws volume lines

  cairo_set_source_rgba(cr,25/255,229/255,214/255,1)
  cairo_move_to(cr,xpos,ypos)
  cairo_rel_line_to(cr,endx,volpos)

  cairo_stroke(cr)
-- restore orginal rotation

end

function volText()

  local y = 135
  local x = conky_window.width/4
  local fontSlant = CAIRO_FONT_SLANT_NORMAL
  local fontFace  = CAIRO_FONT_WEIGHT_NORMAL
  local fontSize  = 16
  local font      = "Roboto"

  local getVolInfo = conky_parse( "${exec amixer get Master | grep Left: | awk '{print $5}' }" )
  local volFilter  = string.gsub(getVolInfo, '[%c%p%s]','')*5

  createText(x,y,font,fontSize,25,229,214,1,fontSlant,fontFace,volFilter.."%")

  print(volFilter*1)

end

function conky_main()

  if conky_window == nil then return end

  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
        cr = cairo_create(cs)
  updates=tonumber(conky_parse('${updates}'))

      if updates>5 then
--##############################
        volume()
        volText()

      end-- if updates>5

cairo_destroy(cr)
cairo_surface_destroy(cs)
cr=nil
end -- end main function
