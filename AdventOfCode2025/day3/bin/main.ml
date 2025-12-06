let get_highest_number_and_index l =
    let (t, _) = List.fold_left (
        fun ((highest, highest_index), index) i -> 
            if i > highest then 
                ((i, index), index + 1) 
        else 
            ((highest, highest_index), index + 1)
    ) ((0, 0), 0) (List.rev l) in
    t

let rec first_n k xs = match xs with
| [] -> failwith "firstk"
| x::xs -> if k=1 then [x] else x::first_n (k-1) xs

let slice_at_index l index =
    let rec loop (i, acc) =
        match acc with
        | [] -> failwith "too far"
        | _ :: tail -> if i == index then tail else loop (i + 1, tail)
    in
    loop (0, List.rev l)

let highest_n n l =
    let rec loop acc n l =
        match n with
        | 0 -> acc
        | n -> 
            let list_first_n_items = first_n (List.length l - n + 1) (List.rev l) |> List.rev  in
            let (highest, highest_index) = get_highest_number_and_index list_first_n_items in
            let remaining_list = slice_at_index l highest_index in
            loop (highest :: acc) (n - 1) (List.rev remaining_list)
        in
    loop [] n l
            
let string_to_int_list l =
    l 
    |> String.to_seq  
    |> List.of_seq 
    |> List.fold_left (fun acc i -> ((int_of_char i) - (int_of_char '0')) :: acc) []

let num_from_int_list l =
    let rec loop acc index l =
        match l with
        | [] -> acc
        | head :: tail -> loop (acc + index * head) (index * 10) tail
    in
    loop 0 1 l
            


let solve lines =
    let nums_part1 = List.fold_left (
        fun acc line -> (line |> string_to_int_list |> (highest_n 2)) :: acc
    ) [] lines in

    let part1 = List.fold_left (+) 0 (List.map num_from_int_list nums_part1) in

    let nums_part2 = List.fold_left (
        fun acc line -> (line |> string_to_int_list |> (highest_n 12)) :: acc
    ) [] lines in

    let part2 = List.fold_left (+) 0 (List.map num_from_int_list nums_part2) in

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
print_endline "Day 3";
  let part1, part2 =
    read_lines "./input.txt" |> solve
  in
  Printf.printf "Part 1: %s\nPart 2: %s\n" (string_of_int part1)
    (string_of_int part2)


