
(* This file is free software. See file "license" for more details. *)

(** {1 Pretty-Printing of nested Boxes}

    Allows to print nested boxes, lists, arrays, tables in a nice way
    on any monospaced support.

    {[
      # let b = PrintBox.(
          frame
            (vlist [ line "hello";
                     hlist [line "world"; line "yolo"]])
        );;
      val b : t = <abstr>

      # PrintBox.output ~indent:2 stdout b;;
      +----------+
      |hello     |
      |----------|
      |world|yolo|
      +----------+
      - : unit = ()

      # let b2 = PrintBox.(
          frame
            (hlist [ text "I love\nto\npress\nenter";
                     grid_text [| [|"a"; "bbb"|];
                                  [|"c"; "hello world"|] |]])
        );;
      val b2 : PrintBox.t = <abstr>

      # PrintBox.output stdout b2;;
      +--------------------+
      |I love|a|bbb        |
      |to    |-+-----------|
      |press |c|hello world|
      |enter | |           |
      +--------------------+

     - : unit = ()

    ]}

*)

type position = { x:int ; y: int }
(** Positions are relative to the upper-left corner, that is,
    when [x] increases we go toward the right, and when [y] increases
    we go toward the bottom (same order as a printer) *)

(** {2 Box Combinators} *)

type t

(** The type [t] is now opaque @since 0.2 .
    The type [view] can be used to observe the inside of the box.
    *)
type view = private
  | Empty
  | Text of string list
  | Frame of t
  | Pad of position * t (* vertical and horizontal padding *)
  | Grid of [`Bars | `None] * t array array
  | Tree of int * t * t array (* int: indent *)

val view : t -> view
(** Observe the content of the box.
    @since 0.2 *)

(** A box, either empty, containing directly text,  or a table or
    tree of sub-boxes *)

val empty : t
(** Empty box, of size 0 *)

val line : string -> t
(** Make a single-line box.
    @raise Invalid_argument if the string contains ['\n'] *)

val text : string -> t
(** Any text, possibly with several lines *)

val sprintf : ('a, Buffer.t, unit, t) format4 -> 'a
(** Formatting for {!text} *)

val asprintf : ('a, Format.formatter, unit, t) format4 -> 'a
(** Formatting for {!text}.
    @since 0.2 *)

val lines : string list -> t
(** Shortcut for {!text}, with a list of lines.
    [lines l] is the same as [text (String.concat "\n" l)]. *)

val int_ : int -> t

val bool_ : bool -> t

val float_ : float -> t

val int : int -> t
(** @since 0.2 *)

val bool : bool -> t
(** @since 0.2 *)

val float : float -> t
(** @since 0.2 *)

val frame : t -> t
(** Put a single frame around the box *)

val pad : t -> t
(** Pad the given box with some free space *)

val pad' : col:int -> lines:int -> t -> t
(** Pad with the given number of free cells for lines and columns *)

val vpad : int -> t -> t
(** Pad vertically *)

val hpad : int -> t -> t
(** Pad horizontally *)

val grid :
  ?pad:(t -> t) ->
  ?bars:bool ->
  t array array -> t
(** Grid of boxes (no frame between boxes). The matrix is indexed
    with lines first, then columns. The array must be a proper matrix,
    that is, all lines must have the same number of columns!
    @param framed if [true], each item of the grid will be framed.
      default value is [true] *)

val grid_text :
  ?pad:(t -> t) -> ?bars:bool ->
  string array array -> t
(** Same as {!grid}, but wraps every cell into a {!text} box *)

val transpose : 'a array array -> 'a array array
(** Transpose a matrix *)

val init_grid : ?bars:bool ->
  line:int -> col:int -> (line:int -> col:int -> t) -> t
(** Same as {!grid} but takes the matrix as a function *)

val vlist : ?pad:(t -> t) -> ?bars:bool -> t list -> t
(** Vertical list of boxes *)

val hlist : ?pad:(t -> t) -> ?bars:bool -> t list -> t
(** Horizontal list of boxes *)

val grid_map : ?bars:bool -> ('a -> t) -> 'a array array -> t

val vlist_map : ?bars:bool -> ('a -> t) -> 'a list -> t

val hlist_map : ?bars:bool -> ('a -> t) -> 'a list -> t

val tree : ?indent:int -> t -> t list -> t
(** Tree structure, with a node label and a list of children nodes *)

val mk_tree : ?indent:int -> ('a -> t * 'a list) -> 'a -> t
(** Definition of a tree with a local function that maps nodes to
    their content and children *)

(** {2 Simple Structural Interface} *)

type 'a ktree = unit -> [`Nil | `Node of 'a * 'a ktree list]
type box = t

module Simple : sig
  type t =
    [ `Empty
    | `Pad of t
    | `Text of string
    | `Vlist of t list
    | `Hlist of t list
    | `Table of t array array
    | `Tree of t * t list
    ]

  val of_ktree : t ktree -> t
  (** Helper to convert trees *)

  val map_ktree : ('a -> t) -> 'a ktree -> t
  (** Helper to map trees into recursive boxes *)

  val to_box : t -> box

  val sprintf : ('a, Buffer.t, unit, t) format4 -> 'a
  (** Formatting for [`Text] *)

  val asprintf : ('a, Format.formatter, unit, t) format4 -> 'a
  (** Formatting for [`Text].
      @since 0.2 *)
end

(**/**)

(** Utils *)

val dim_matrix : _ array array -> position
val map_matrix : ('a -> 'b) -> 'a array array -> 'b array array

(**/**)
