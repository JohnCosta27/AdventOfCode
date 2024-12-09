module IntTuple = struct
  type t = int * int

  let compare (x0, y0) (x1, y1) = if x0 == x1 && y0 == y1 then 0 else 1
end

module TupleSet = Set.Make (IntTuple)
module CharMap = Map.Make (Char)

let exponent x n =
  let rec loop acc n = match n with 0 -> acc | _ -> loop (acc * x) (n - 1) in
  loop 1 n

let abs x = if x < 0 then -x else x

let get_coordinates lines freq =
  let rec loop acc y lines =
    match lines with
    | [] -> acc
    | head :: tail ->
        let _, coords =
          String.fold_left
            (fun (i, accc) c ->
              if c == freq then (i + 1, [ (i, y) ] @ accc) else (i + 1, accc))
            (0, []) head
        in
        loop (acc @ coords) (y + 1) tail
  in
  loop [] 0 lines

let distances (x1, y1) (x2, y2) = (x2 - x1, y2 - y1)

let get_anti_nodes c1 c2 =
  let x, y = c1 in
  let dx, dy = distances c1 c2 in
  [ (x + (2 * dx), y + (2 * dy)); (x - dx, y - dy) ]

let get_part2_anti_nodes x_limit y_limit c1 c2 =
  let dx, dy = distances c1 c2 in

  let rec loop (x, y) (dx, dy) acc multiplier =
    let new_x, new_y = (x + (multiplier * dx), y + (multiplier * dy)) in
    if new_x >= 0 && new_x < x_limit && new_y >= 0 && new_y < y_limit then
      loop (x, y) (dx, dy) ([ (new_x, new_y) ] @ acc) (multiplier + 1)
    else acc
  in

  let first = loop c1 (dx, dy) [] 1 in
  let second = loop c2 (-dx, -dy) [] 1 in
  first @ second

let get_frequencies lines =
  let rec loop y map lines =
    match lines with
    | [] -> map
    | head :: tail ->
        let _, m =
          String.fold_left
            (fun (i, acc) c ->
              if c != '.' then
                let new_coord = (i, y) in
                let new_map =
                  CharMap.update c
                    (fun i ->
                      match i with
                      | None -> Some [ new_coord ]
                      | Some l -> Some ([ new_coord ] @ l))
                    acc
                in

                (i + 1, new_map)
              else (i + 1, acc))
            (0, map) head
        in
        loop (y + 1) m tail
  in
  loop 0 CharMap.empty lines

let character_anti_nodes fn m c =
  let coords = CharMap.find c m in

  let rec loop c1 acc node_list =
    match node_list with
    | [] -> acc
    | c2 :: tail ->
        let anti_nodes = fn c1 c2 in
        loop c1 (anti_nodes @ acc) tail
  in

  let rec get_all acc node_list =
    match node_list with
    | [] -> acc
    | c1 :: tail -> get_all (loop c1 [] tail @ acc) tail
  in
  get_all [] coords

let rec exists l (x1, y1) =
  match l with
  | [] -> false
  | (x2, y2) :: tail ->
      if x1 == x2 && y1 == y2 then true else exists tail (x1, y1)

let remove_duplicates l seen =
  let rec loop acc seen l =
    match l with
    | [] -> (acc, seen)
    | head :: tail ->
        let found = exists seen head in
        if not found then
          let new_seen = [ head ] @ seen in
          loop ([ head ] @ acc) new_seen tail
        else loop acc seen tail
  in
  loop [] seen l

(* Gradient signs are all reversed because y going down is + *)
let solve lines =
  let m = get_frequencies lines in
  let all_keys = CharMap.to_list m |> List.map (fun (k, _) -> k) in
  let part1_anti_nodes = character_anti_nodes get_anti_nodes in
  let part2_anti_nodes =
    character_anti_nodes
      (get_part2_anti_nodes
         (String.length (List.nth lines 0))
         (List.length lines))
  in

  let sum_anti_nodes fn =
    List.fold_left
      (fun (acc, seen) c ->
        let anti_nodes, new_seen = remove_duplicates (fn m c) seen in
        let valid_anti_nodes =
          List.filter
            (fun (x, y) ->
              x >= 0
              && x < String.length (List.nth lines 0)
              && y >= 0
              && y < List.length lines)
            anti_nodes
        in
        (acc + List.length valid_anti_nodes, new_seen))
      (0, []) all_keys
  in

  let part1, _ = sum_anti_nodes part1_anti_nodes in
  let part2, _ = sum_anti_nodes part2_anti_nodes in
  (part1, part2)
