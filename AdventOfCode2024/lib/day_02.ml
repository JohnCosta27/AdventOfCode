open Scanf

let handle_line line = sscanf line "%d   %d" (fun num1 num2 -> (num1, num2))
let sort_list l = List.sort compare l
let print_list l = List.iter (Printf.printf "%d ") l

let line_to_list line =
  String.split_on_char ' ' line |> List.map (fun i -> int_of_string i)

let is_valid_report l =
  let rec increasing l =
    match l with
    | [] -> true
    | [ _ ] -> true
    | head :: h2 :: tail ->
        if head >= h2 || h2 - head > 3 then false else increasing ([ h2 ] @ tail)
  in
  let rec decreasing l =
    match l with
    | [] -> true
    | [ _ ] -> true
    | head :: h2 :: tail ->
        if head <= h2 || head - h2 > 3 then false else decreasing ([ h2 ] @ tail)
  in

  match l with
  | [] -> true
  | [ _ ] -> true
  | h1 :: h2 :: tail ->
      if h1 > h2 then decreasing ([ h1; h2 ] @ tail)
      else increasing ([ h1; h2 ] @ tail)

let rec range x y = if x > y then [] else x :: range (x + 1) y

let list_premutations l =
  let rec loop original_list nth index acc =
    match original_list with
    | [] -> acc
    | head :: tail ->
        if index == nth then loop tail nth (index + 1) acc
        else loop tail nth (index + 1) ([ head ] @ acc)
  in
  let indexes = range 0 (List.length l - 1) in

  let premutations =
    List.fold_left
      (fun acc index -> [ List.rev (loop l index 0 []) ] @ acc)
      [] indexes
  in
  premutations

let list_or l =
  let rec loop l' acc =
    match l' with [] -> acc | head :: tail -> head || loop tail acc
  in
  loop l false

let solve lines =
  let reports = List.map line_to_list lines in
  let part1 =
    List.fold_left
      (fun acc i -> if is_valid_report i then acc + 1 else acc)
      0 reports
  in
  let premutations = List.map list_premutations reports in

  let attempted_gaps =
    List.map (fun i -> List.map is_valid_report i) premutations
  in

  let part2 =
    List.fold_left
      (fun acc bool_list -> if list_or bool_list then acc + 1 else acc)
      0 attempted_gaps
  in
  (part1, part2)
