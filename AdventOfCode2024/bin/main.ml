open Scanf

let read_lines name =
  let ic = open_in name in
  let try_read () =
    try Some (input_line ic) with End_of_file -> None in
  let rec loop acc = match try_read () with
    | Some s -> loop (s :: acc)
    | None -> close_in ic; List.rev acc in
  loop []

let handle_line line =
    sscanf line "%d   %d" (fun num1 num2 -> (num1, num2))

let sort_list l =
    List.sort compare l

let build_lists lines =
    let rec loop lines l1 l2 = match lines with
        | [] -> (l1, l2)
        | head :: tail -> 
            let (num1, num2) = handle_line head in
            loop tail (l1 @ [num1]) (l2 @ [num2]) in
    loop lines [] [] |> (fun (l1, l2) -> (sort_list l1, sort_list l2))

let find_occurances l item =
    let rec loop l item acc = match l with
        | [] -> acc
        | head :: tail -> if head == item then loop tail item (acc + 1) else loop tail item acc in
    loop l item 0

let () = 
    print_endline "\nAdvent of Code 2024";
    let lines = read_lines "./bin/input.txt" in

    let rec distance l1 l2 acc =
        match (l1, l2) with
            | ([], []) -> acc
            | (h1 :: t1, h2 :: t2) ->
                distance t1 t2 (acc + if h1 > h2 then h1 - h2 else h2 - h1)
            | _, _ -> acc in

    let (l1, l2) = build_lists lines in
    let part1 = distance l1 l2 0 in
    Printf.printf "Part 1: %s\n" (string_of_int part1);

    let rec similarity l1 l2 acc =
        match l1 with
            | [] -> acc
            | head :: tail -> similarity tail l2 (acc + head * find_occurances l2 head) in
    
    let part2 = similarity l1 l2 0 in
    Printf.printf "Part 2: %s\n" (string_of_int part2);
