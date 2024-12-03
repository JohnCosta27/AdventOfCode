let rec print_list l =
  match l with
  | [] -> print_endline ""
  | head :: tail ->
      print_int head;
      print_string " | ";
      print_list tail

let rec print_s_list l =
  match l with
  | [] -> print_endline ""
  | head :: tail ->
      print_string head;
      print_string " | ";
      print_s_list tail

let rec print_tuple_list l =
  match l with
  | [] -> print_endline ""
  | (index, value) :: tail ->
      print_int index;
      print_string ", ";
      print_string (string_of_bool value);
      print_string " | ";
      print_tuple_list tail

let get_toggle_positions line =
  let toggle_on_regex = Re2.create_exn {|do\(\)|} in
  let toggle_off_regex = Re2.create_exn {|don't\(\)|} in
  let on_matches = Re2.get_matches_exn toggle_on_regex line in
  let off_matches = Re2.get_matches_exn toggle_off_regex line in
  let get_indexes =
    List.fold_left
      (fun acc i ->
        let start, _ = Re2.Match.get_pos_exn ~sub:(`Index 0) i in
        [ start ] @ acc)
      []
  in

  let on_indexes = get_indexes on_matches in
  let off_indexes = get_indexes off_matches in
  List.sort
    (fun (i, _) (j, _) -> i - j)
    ((List.rev on_indexes |> List.map (fun i -> (i, true)))
    @ (List.rev off_indexes |> List.map (fun i -> (i, false))))

let get_all_numbers_positions line =
  let instruction_regex = Re2.create_exn {|mul\((\d+),(\d+)\)|} in
  let matches_indexes = Re2.get_matches_exn instruction_regex line in
  let indexes =
    List.fold_left
      (fun acc i ->
        let start, _ = Re2.Match.get_pos_exn ~sub:(`Index 0) i in
        [ start ] @ acc)
      [] matches_indexes
  in
  List.rev indexes

let get_all_numbers line =
  let instruction_regex = Re2.create_exn {|mul\((\d+),(\d+)\)|} in
  let matches = Re2.find_all_exn instruction_regex line in
  let nums =
    List.fold_left
      (fun acc m ->
        let num1, num2 = Scanf.sscanf m "mul(%d,%d)" (fun n1 n2 -> (n1, n2)) in
        [ (num1, num2) ] @ acc)
      [] matches
  in
  List.rev nums

let get_closest_item l item starting =
  let rec get_closest_item' l closest item =
    match l with
    | [] -> closest
    | (head, v) :: tail ->
        if head < item then get_closest_item' tail (head, v) item else closest
  in
  get_closest_item' l (0, starting) item

let solve lines =
  let part1 =
    List.fold_left
      (fun acc line ->
        let line_value =
          List.fold_left
            (fun acc (num1, num2) -> acc + (num1 * num2))
            0 (get_all_numbers line)
        in
        acc + line_value)
      0 lines
  in

  let part2, _ =
    List.fold_left
      (fun (acc, toggle) line ->
        let mul_indexes = get_all_numbers_positions line in
        let mul_intructions = get_all_numbers line in
        let toggles = get_toggle_positions line in
        let closest_check = get_closest_item toggles in

        let rec loop indexes instructions acc last_toggle =
          match (indexes, instructions) with
          | [], [] -> (acc, last_toggle)
          | head :: tail, (n1, n2) :: in_tail ->
              let _, is_on = closest_check head toggle in

              let acc' = if is_on then acc + (n1 * n2) else acc in
              loop tail in_tail acc' is_on
          | _ -> (acc, last_toggle)
        in

        let acc', last_toggle = loop mul_indexes mul_intructions 0 toggle in
        (acc + acc', last_toggle))
      (0, true) lines
  in

  (part1, part2)
