module IntTuple = struct
  type t = int * int

  let compare (x0, y0) (x1, y1) =
    if x0 == x1 && y0 == y1 then 0 else if x0 > x1 then 1 else -1
end

module TupleSet = Set.Make (IntTuple)

let find_starts grid =
  let x_list = List.init (Array.length grid.(0)) (fun i -> i) in
  let y_list = List.init (Array.length grid) (fun i -> i) in

  List.fold_left
    (fun acc y ->
      acc
      @ List.fold_left
          (fun acc x -> if grid.(y).(x) == 0 then acc @ [ (x, y) ] else acc)
          [] x_list)
    [] y_list

let is_in_bounds grid (x, y) =
  y >= 0 && y < Array.length grid && x >= 0 && x < Array.length grid.(0)

let directions = [ (1, 0); (-1, 0); (0, 1); (0, -1) ]

let print_set s =
  print_endline ">>>>>>>>>";
  TupleSet.iter
    (fun (x, y) ->
      Printf.printf "%d,%d" (y + 1) (x + 1);
      print_endline "")
    s;
  print_endline "<<<<<<<<<"

let print_node (x, y) = Printf.printf "Node: %d,%d\n" (y + 1) (x + 1)

let find_hikes grid start =
  let rec dfs node visited =
    let new_visited = TupleSet.add node visited in
    let x, y = node in
    if grid.(y).(x) == 9 then (1, new_visited)
    else
      let to_visit =
        List.fold_left
          (fun acc (dx, dy) ->
            let new_x, new_y = (x + dx, y + dy) in
            if not (is_in_bounds grid (new_x, new_y)) then acc
            else if grid.(new_y).(new_x) - grid.(y).(x) != 1 then acc
            else acc @ [ (x + dx, y + dy) ])
          [] directions
      in
      List.fold_left
        (fun (score, v) n ->
          let x, y = n in
          let new_score, new_v =
            if TupleSet.exists (fun (x', y') -> x' == x && y' == y) v then (0, v)
            else dfs n v
          in
          (score + new_score, TupleSet.union v new_v))
        (0, new_visited) to_visit
  in
  dfs start TupleSet.empty

let find_hikes_part2 grid start =
  let rec dfs node visited =
    let new_visited = TupleSet.add node visited in
    let x, y = node in
    if grid.(y).(x) == 9 then (1, new_visited)
    else
      let to_visit =
        List.fold_left
          (fun acc (dx, dy) ->
            let new_x, new_y = (x + dx, y + dy) in
            if not (is_in_bounds grid (new_x, new_y)) then acc
            else if grid.(new_y).(new_x) - grid.(y).(x) != 1 then acc
            else acc @ [ (x + dx, y + dy) ])
          [] directions
      in
      let score, visited_list =
        List.fold_left
          (fun (score, l) n ->
            let x, y = n in
            let new_score, new_v =
              if
                TupleSet.exists (fun (x', y') -> x' == x && y' == y) new_visited
              then (0, new_visited)
              else dfs n new_visited
            in
            (score + new_score, l @ [ new_v ]))
          (0, []) to_visit
      in
      (score, List.fold_left TupleSet.union new_visited visited_list)
  in
  dfs start TupleSet.empty

let solve lines =
  let grid =
    Array.init (List.length lines) (fun i ->
        Array.init
          (String.length (List.nth lines 0))
          (fun j ->
            let str = String.get (List.nth lines i) j |> Char.escaped in
            if String.equal str "." then -1 else int_of_string str))
  in
  let zeroes = find_starts grid in
  let hikes = List.map (fun zero -> find_hikes grid zero) zeroes in
  let hikes_part2 = List.map (fun zero -> find_hikes_part2 grid zero) zeroes in
  let part1 =
    List.map (fun (score, _) -> score) hikes
    |> List.fold_left (fun acc score -> acc + score) 0
  in
  let part2 =
    List.map (fun (score, _) -> score) hikes_part2
    |> List.fold_left (fun acc score -> acc + score) 0
  in
  (part1, part2)
