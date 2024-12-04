let check_at grid x y =
  if x < 0 || x >= Array.length grid.(0) || y < 0 || y >= Array.length grid then
    None
  else Some grid.(y).(x)

let get_next_char c =
  match c with
  | 'M' -> 'A'
  | 'A' -> 'S'
  | _ -> raise (Invalid_argument "cant put this here")

let rec check_work_in_direction grid x y starting_char direction path =
  let dx, dy = direction in
  let grid_char = check_at grid (x + dx) (y + dy) in
  match grid_char with
  | None -> 0
  | Some c ->
      if c != starting_char then 0
      else if c == 'S' then 1
      else
        check_work_in_direction grid (x + dx) (y + dy)
          (get_next_char starting_char)
          direction
          ([ (x + dx, y + dy) ] @ path)

let is_char op cc = match op with None -> false | Some c -> c == cc

let check_word_part2 grid x y =
  let grid_char = check_at grid x y in
  match grid_char with
  | None -> false
  | Some 'A' ->
      let top_left = check_at grid (x - 1) (y - 1) in
      let top_right = check_at grid (x + 1) (y - 1) in
      let bottom_left = check_at grid (x - 1) (y + 1) in
      let bottom_right = check_at grid (x + 1) (y + 1) in

      let is_back_diagal_mas =
        (is_char top_left 'S' && is_char bottom_right 'M')
        || (is_char top_left 'M' && is_char bottom_right 'S')
      in

      let is_forward_diagal_mas =
        (is_char top_right 'S' && is_char bottom_left 'M')
        || (is_char top_right 'M' && is_char bottom_left 'S')
      in

      is_back_diagal_mas && is_forward_diagal_mas
  | Some _ -> false

let check_word grid x y =
  let grid_char = check_at grid x y in
  let curried_check = check_work_in_direction grid x y 'M' in
  match grid_char with
  | None -> 0
  | Some 'X' ->
      curried_check (-1, -1) [ (x, y) ]
      + curried_check (0, -1) [ (x, y) ]
      + curried_check (1, -1) [ (x, y) ]
      + curried_check (-1, 0) [ (x, y) ]
      + curried_check (1, 0) [ (x, y) ]
      + curried_check (-1, 1) [ (x, y) ]
      + curried_check (0, 1) [ (x, y) ]
      + curried_check (1, 1) [ (x, y) ]
  | Some _ -> 0

let solve lines =
  let grid =
    Array.init (List.length lines) (fun i ->
        Array.init
          (String.length (List.nth lines 0))
          (fun j -> String.get (List.nth lines i) j))
  in

  let x_list = List.init (Array.length grid.(0)) (fun i -> i) in
  let y_list = List.init (Array.length grid) (fun i -> i) in

  let part1 =
    List.fold_left
      (fun acc y ->
        acc + List.fold_left (fun acc x -> acc + check_word grid x y) 0 x_list)
      0 y_list
  in
  let part2 =
    List.fold_left
      (fun acc y ->
        acc
        + List.fold_left
            (fun acc x -> acc + if check_word_part2 grid x y then 1 else 0)
            0 x_list)
      0 y_list
  in
  (part1, part2)
