
exception Not_image

(** Cairo version of the turtle *)
class cairo_turtle size_x size_y context surface =
  object inherit Graphic_order.turtle as super

    (* We do the scaling and the rounding by ourself here because cairo do it too slowly *)
    method move ?(trace=true) d =
      super#move ~trace d ;
      if trace 
      then Cairo.line_to context (floor (size_x *. x)) (floor (size_y *. y))
      else Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

    method restore_position () = 
      super#restore_position () ;
      Cairo.move_to context (floor (size_x *. x)) (floor (size_y *. y))

    (** Fill the picture with solid white and set the color to solid black *)
    method fill () =
      Cairo.set_source_rgb context 1. 1. 1.;
      Cairo.paint context ~alpha:1.;
      Cairo.set_source_rgba context 0. 0. 0. 1.

    (** Apply drawing on the surface *)
    method draw () = 
      Cairo.stroke context

  end
  
(** A turtle that write to a png file *)
class png_turtle size_x size_y = 
  
  let surface = Cairo.Image.create Cairo.Image.ARGB32 size_x size_y in
  let ctx = Cairo.create surface in
  let _ = Cairo.set_line_width ctx 1. in
  
  object inherit cairo_turtle (float size_x) (float size_y) ctx surface
	
    (** Draw to a png *)
    method finish file =
      Cairo.stroke ctx ; 
      Cairo.PNG.write surface file
  end

(** A turtle that write to a svg file *)
class svg_turtle outfile size_x size_y = 
  
  let width, height = (float size_x), (float size_y) in
  let buffer = open_out outfile in
  let surface = Cairo.SVG.create_for_stream ~output:(output_string buffer) ~width ~height in
  let ctx = Cairo.create surface in
  let _ = Cairo.set_line_width ctx 1. in
  
  object inherit cairo_turtle width height ctx surface as super

    method move  ?(trace=true) d =
      super#move ~trace d ;
      Cairo.stroke ctx ;
      Cairo.move_to ctx (floor (width *. x)) (floor (height *. y))

    method finish () = 
      Cairo.stroke ctx ; 
      Cairo.Surface.flush surface ;
      flush buffer ;
      close_out buffer ;
  end

(** A turtle that write on a gtk surface *)
class gtk_turtle w =
  let ctx = Cairo_gtk.create w#misc#window in
  let { Gtk.width = size_x ; Gtk.height = size_y } = w#misc#allocation in
  let surface = Cairo.get_target ctx in
  let _ = Cairo.set_line_width ctx 1. in
  
  object inherit cairo_turtle (float size_x) (float size_y) ctx surface

  end 
