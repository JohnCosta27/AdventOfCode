module IntTuple = struct
  type t = int * int * int * int

  let compare (x0, y0, z0, w0) (x1, y1, z1, w1) =
    if x0 == x1 && y0 == y1 && z0 == z1 && w0 == w1 then 0 else 1
end

module IntTupleSet = Set.Make (IntTuple)

let find_position lines =
  let rec loop list_index lines =
    match lines with
    | [] -> raise (Invalid_argument "not found")
    | head :: tail -> (
        match String.index_from_opt head 0 '^' with
        | None -> loop (list_index + 1) tail
        | Some i -> (list_index, i))
  in
  loop 0 lines

let remove_list_duplicates l =
  let rec loop acc l =
    match l with
    | [] -> acc
    | (y1, x1) :: tail ->
        if List.exists (fun (y2, x2) -> x1 == x2 && y1 == y2) acc then
          loop acc tail
        else loop ([ (y1, x1) ] @ acc) tail
  in
  loop [] l

let get_direction_change direction =
  match direction with
  | -1, 0 -> (0, 1)
  | 1, 0 -> (0, -1)
  | 0, 1 -> (1, 0)
  | 0, -1 -> (-1, 0)
  | _ -> raise (Invalid_argument "not valid direction")

let is_out_of_bounds l (y, x) =
  y < 0 || y >= List.length l || x < 0 || x >= String.length (List.nth l 0)

let is_in_loop visited (y, x) (dy, dx) =
  List.exists
    (fun (y1, x1, dy1, dx1) -> y1 == y && x1 == x && dy1 == dy && dx1 == dx)
    visited

let positions_visited lines (y, x) =
  let rec loop positions (y, x) (dy, dx) =
    if is_out_of_bounds lines (y, x) then positions
    else
      let loop_with_pos = loop ([ (y, x) ] @ positions) in
      let next_pos = (y + dy, x + dx) in

      if is_out_of_bounds lines next_pos then loop_with_pos next_pos (dy, dx)
      else
        let next_tile = String.get (List.nth lines (y + dy)) (x + dx) in
        if next_tile == '#' then
          let new_dy, new_dx = get_direction_change (dy, dx) in
          loop_with_pos (y, x) (new_dy, new_dx)
        else loop_with_pos (y + dy, x + dx) (dy, dx)
  in
  loop [] (y, x) (-1, 0)

let check_loop lines (y, x) =
  let rec loop positions (y, x) (dy, dx) =
    if is_out_of_bounds lines (y, x) then false
    else if IntTupleSet.mem (y, x, dy, dx) positions then true
    else
      let incremented_set = IntTupleSet.add (y, x, dy, dx) positions in
      let loop_with_pos = loop incremented_set in
      let next_pos = (y + dy, x + dx) in

      if is_out_of_bounds lines next_pos then loop_with_pos next_pos (dy, dx)
      else
        let next_tile = String.get (List.nth lines (y + dy)) (x + dx) in
        if next_tile == '#' then
          let new_dy, new_dx = get_direction_change (dy, dx) in
          loop_with_pos (y, x) (new_dy, new_dx)
        else loop_with_pos (y + dy, x + dx) (dy, dx)
  in
  loop IntTupleSet.empty (y, x) (-1, 0)

let add_obstacle lines (y, x) =
  List.mapi
    (fun i ->
      fun _ ->
       if i == y then
         let row = List.nth lines y in
         let mapped_str =
           String.mapi
             (fun j -> fun _ -> if j == x then '#' else String.get row j)
             row
         in
         mapped_str
       else List.nth lines i)
    lines

let solve lines =
  let initial_position = find_position lines in
  let visited =
    positions_visited lines initial_position |> remove_list_duplicates
  in
  let part1 = List.length visited in

  let x_list = List.init (List.nth lines 0 |> String.length) (fun i -> i) in
  let y_list = List.init (List.length lines) (fun i -> i) in

  (* 
   #
   .#
   *)
  let part2 =
    List.fold_left
      (fun acc y ->
        acc
        + List.fold_left
            (fun acc x ->
              let initial_y, initial_x = initial_position in
              if
                List.exists (fun (y1, x1) -> y1 == y && x1 == x) visited
                || (y == initial_y && x == initial_x)
              then (
                let new_lines = add_obstacle lines (y, x) in
                print_endline (List.nth new_lines 0);
                Printf.printf "%d,%d\n" (y + 1) (x + 1);
                if check_loop new_lines initial_position then acc + 1 else acc)
              else acc)
            0 x_list)
      0 y_list
  in

  (part1, part2)
