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
  print_endline "\nAdvent of Code 2024";
  let part1, part2 =
    read_lines "./inputs/10.txt" |> AdventOfCode2024.Day_10.solve
  in
  Printf.printf "Part 1: %s\nPart 2: %s\n" (string_of_int part1)
    (string_of_int part2)
