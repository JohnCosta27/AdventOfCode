module IntMap = Map.Make (Int)

let rec print_list l =
  match l with
  | [] -> print_endline ""
  | head :: tail ->
      print_int head;
      print_string ",";
      print_list tail

let option_to_val op =
  match op with None -> raise (Invalid_argument "assertion") | Some v -> v

let sublist list low high = List.filteri (fun i _ -> i >= low && i < high) list

let add_rule_to_map (m : int list IntMap.t) rule =
  let num1, num2 = Scanf.sscanf rule "%d|%d" (fun n1 n2 -> (n2, n1)) in
  let existing_rules =
    IntMap.update num1
      (fun l ->
        match l with
        | None -> Some [ num2 ]
        | Some existing_rules -> Some ([ num2 ] @ existing_rules))
      m
  in
  existing_rules

(*
4 | 2
2 | 3

1, 2, 3 
  /\

prev_list = [1]
pages_needed = [4, 7]

 *)

let rec is_sublist main_list sub_list =
  match sub_list with
  | [] -> true
  | head :: tail ->
      if List.exists (fun i -> head == i) main_list then
        is_sublist main_list tail
      else false

let is_case_valid m case =
  let rec loop prev_pages remaining_pages =
    match remaining_pages with
    | [] -> true
    | head :: tail -> (
        let pages_needed_before = IntMap.find_opt head m in
        match pages_needed_before with
        | None -> loop ([ head ] @ prev_pages) tail
        | Some l ->
            if
              is_sublist prev_pages
                (List.filter (fun i -> List.exists (fun j -> j == i) case) l)
            then loop ([ head ] @ prev_pages) tail
            else false)
  in
  loop [] case

let partial_sort m case =
  List.sort
    (fun i j ->
      let pages_needed_i = IntMap.find_opt i m in
      let pages_needed_j = IntMap.find_opt j m in

      match (pages_needed_i, pages_needed_j) with
      | None, None -> 0
      | Some _, None -> 1
      | None, Some _ -> -1
      | Some pages_i, Some _ ->
          if List.exists (fun i -> i == j) pages_i then 1 else -1)
    case

let solve lines =
  let rule_map : int list IntMap.t = IntMap.empty in

  let empty_index =
    List.find_index (fun i -> String.length i == 0) lines |> option_to_val
  in
  let rules = sublist lines 0 empty_index in
  let cases = sublist lines (empty_index + 1) (List.length lines) in
  let string_cases =
    List.fold_left
      (fun acc case ->
        [ String.split_on_char ',' case |> List.map int_of_string ] @ acc)
      [] cases
  in

  let map_with_rules = List.fold_left add_rule_to_map rule_map rules in
  let is_case_valid_with_map = is_case_valid map_with_rules in

  let part1 =
    List.fold_left
      (fun acc case ->
        if is_case_valid_with_map case then
          acc + List.nth case (List.length case / 2)
        else acc)
      0 string_cases
  in

  let invalid_cases =
    List.filter (fun case -> is_case_valid_with_map case == false) string_cases
  in

  let sorted_invalid_cases =
    List.map (fun case -> partial_sort map_with_rules case) invalid_cases
  in

  let part2 =
    List.fold_left
      (fun acc case -> acc + List.nth case (List.length case / 2))
      0 sorted_invalid_cases
  in

  (part1, part2)
