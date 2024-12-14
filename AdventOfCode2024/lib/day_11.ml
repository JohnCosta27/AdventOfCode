let line_to_numbers line =
  String.split_on_char ' ' line |> List.map int_of_string

module IntMap = Map.Make (Int)

let num_of_digits num = (float_of_int num |> log10 |> int_of_float) + 1

let split_stone num =
  let digits = num_of_digits num in
  let num_str = string_of_int num in
  let first_half = String.sub num_str 0 (digits / 2) |> int_of_string in
  let second_half =
    String.sub num_str (digits / 2) (digits / 2) |> int_of_string
  in
  (first_half, second_half)

let upsert k v map =
  IntMap.update k
    (fun existing ->
      match existing with None -> Some v | Some i -> Some (i + v))
    map

let blink map =
  IntMap.fold
    (fun k v acc ->
      if k == 0 then upsert 1 v acc
      else if num_of_digits k mod 2 == 0 then
        let first_stone, second_stone = split_stone k in
        upsert first_stone v acc |> upsert second_stone v
      else upsert (k * 2024) v acc)
    map IntMap.empty

let blink_times map times =
  let rec loop acc times' =
    match times' with 0 -> acc | t -> loop (blink acc) (t - 1)
  in
  loop map times

let print_map map = IntMap.iter (Printf.printf "Key: %d, Value: %d\n") map

let solve lines =
  let line = List.nth lines 0 in
  let nums = line_to_numbers line in

  let filled_map =
    List.fold_left
      (fun acc i ->
        IntMap.update i
          (fun item ->
            match item with None -> Some 1 | Some in_map -> Some (in_map + 1))
          acc)
      IntMap.empty nums
  in

  let part1 =
    blink_times filled_map 25 |> IntMap.to_list
    |> List.fold_left (fun acc (_, v) -> acc + v) 0
  in

  let part2 =
    blink_times filled_map 75 |> IntMap.to_list
    |> List.fold_left (fun acc (_, v) -> acc + v) 0
  in
  (part1, part2)
