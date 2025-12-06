let get_range str =
    let list = (String.split_on_char '-' str) 
        |> List.map int_of_string in

    assert (List.length list == 2);
    
    let lower = List.nth list 0 in
    let upper = List.nth list 1 in

    (lower, upper)

let is_item_in_range  i (lower, upper) = 
    lower <= i && i <= upper

let rec list_some l fn = 
    match l with 
    | [] -> false
    | head :: tail -> if fn head then true else list_some tail fn

let is_item_in_ranges ranges i =
    list_some ranges (is_item_in_range i)


let is_overlapping (lower1, upper1) (lower2, upper2) =
    lower1 <= lower2 && lower2 <= upper1 ||
    lower2 <= lower1 && lower1 <= upper2

let get_combined_ranges (lower1, upper1) (lower2, upper2) =
    let lower = min lower1 lower2 in
    let upper = max upper1 upper2 in
    (lower, upper)

let non_overlapping_ranges_work ranges =
    let rec loop acc changes ranges =
        match ranges with 
        | [] -> (acc, changes)
        | head :: tail -> 
            let overlap_fn = is_overlapping head in
            let overlapping_index = List.find_index overlap_fn tail in
            match overlapping_index with
            | Some r -> 
                let (l, u) = List.nth tail r in
                let tail_without_index = List.filter 
                    (fun (lower, upper) -> not (lower == l && upper == u)) tail in
                let combined_range = get_combined_ranges head (l, u) in
                loop (combined_range :: acc) true (tail_without_index)
            | None -> loop (head :: acc) changes tail
    in
    loop [] false ranges

(* let rec print_ranges l = *)
(*     match l with  *)
(*     | [] -> print_endline ""; *)
(*     | (lower, upper) :: tail ->  *)
(*         Printf.printf "lower=%d,upper=%d\n" lower upper; *)
(*         print_ranges tail *)
        

let rec non_overlapping_ranges ranges =
    let (ranges, changes)  = non_overlapping_ranges_work ranges in
    if changes then non_overlapping_ranges ranges
    else ranges

    
let solve lines = 
    let no_empty_lines = List.filter (fun i -> String.length i > 0) lines in
    let (ranges, items) = List.partition (fun i -> String.contains i '-') no_empty_lines in

    let ranges = List.map get_range ranges in
    let items = List.map int_of_string items in

    let part1 = List.fold_left (
        fun acc i -> if is_item_in_ranges ranges i then acc + 1 else acc
    ) 0 items in

    let ranges = non_overlapping_ranges ranges in
     
    let part2 = List.fold_left (
        fun acc (lower, upper) -> acc + (upper - lower + 1)
    ) 0 ranges in

    (part1, part2)









































let read_lines name =
  let ic = open_in name in
  let try_read () = try Some (input_line ic) with End_of_file -> None in
  let rec loop acc =
    match try_read () with
    | Some s -> loop (s :: acc)
    | None ->
        close_in ic;
        List.rev acc
  in
  loop []

let () =
print_endline "Day 5";
  let part1, part2 =
    read_lines "./input.txt" |> solve
  in
  Printf.printf "Part 1: %s\nPart 2: %s\n" (string_of_int part1)
    (string_of_int part2)


