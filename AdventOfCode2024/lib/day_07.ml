type equation = { equals : int; numbers : int list }

let rec print_list l =
  match l with
  | [] -> print_endline ""
  | head :: tail ->
      print_int head;
      print_string ",";
      print_list tail

let equation_from_line line =
  let first_num = Scanf.sscanf line "%d:" (fun n1 -> n1) in
  let rest_of_numbers =
    List.nth (String.split_on_char ':' line) 1
    |> String.trim |> String.split_on_char ' '
  in
  let numbers = List.map int_of_string rest_of_numbers in
  { equals = first_num; numbers }

let attempt_solve { equals; numbers } =
  (* [1, 2] *)
  let rec loop numbers =
    match numbers with
    | head :: [] -> [ head ]
    | head :: tail ->
        let plus = List.map (fun i -> i + head) (loop tail) in
        let times = List.map (fun i -> i * head) (loop tail) in
        plus @ times
    | _ -> raise (Invalid_argument "")
  in
  let possibilities = loop (List.rev numbers) in
  if List.exists (fun i -> i == equals) possibilities then equals else 0

let attempt_solve_part2 { equals; numbers } =
  (* [1, 2] *)
  let rec loop numbers =
    match numbers with
    | head :: [] -> [ head ]
    | head :: tail ->
        let below_solution = List.filter (fun i -> i <= equals) (loop tail) in
        let plus = List.map (fun i -> i + head) below_solution in
        let times = List.map (fun i -> i * head) below_solution in
        let concat =
          List.map
            (fun i ->
              let i_string = string_of_int i in
              let head_string = string_of_int head in
              int_of_string (i_string ^ head_string))
            below_solution
        in
        plus @ times @ concat
    | _ -> raise (Invalid_argument "")
  in
  let possibilities = loop (List.rev numbers) in
  if List.exists (fun i -> i == equals) possibilities then equals else 0

let solve lines =
  let part1 =
    List.fold_left
      (fun acc line -> acc + (equation_from_line line |> attempt_solve))
      0 lines
  in
  let part2 =
    List.fold_left
      (fun acc line -> acc + (equation_from_line line |> attempt_solve_part2))
      0 lines
  in
  (part1, part2)
