type block = { amount : int; id : int }
type space = { amount : int }
type slot = Block of block | Space of space

let expand_file_system line =
  let rec loop acc line' id =
    match line' with
    | "" -> acc
    | s ->
        if String.length s == 1 then
          acc @ [ Block { amount = int_of_string s; id } ]
        else
          let block = String.get s 0 |> Char.escaped in
          let space = String.get s 1 |> Char.escaped in
          let remaining = String.sub s 2 (String.length s - 2) in
          let with_block =
            acc @ [ Block { amount = int_of_string block; id } ]
          in

          let space_amount = int_of_string space in
          if space_amount > 0 then
            loop
              (with_block @ [ Space { amount = int_of_string space } ])
              remaining (id + 1)
          else loop with_block remaining (id + 1)
  in
  loop [] line 0

let remove_last_item l =
  if List.length l == 0 then None
  else
    let rev = List.rev l in
    let last_item = List.hd rev in
    let remaning = List.tl rev in
    Some (last_item, List.rev remaning)

let rec print_list l =
  match l with
  | [] -> ()
  | head :: tail ->
      (match head with
      | Block b -> Printf.printf "Block | ID = %d, Amount = %d\n" b.id b.amount
      | Space s -> Printf.printf "Space | Amount = %d\n" s.amount);
      print_list tail

(* 00...111...2...333.44.5555.6666.777.888899 *)

(* 0099811188827773336446555566 *)

let defrag_file_system fs =
  let rec loop acc fs' =
    match fs' with
    | [] -> acc
    | head :: tail -> (
        match head with
        | Block b -> loop (acc @ [ Block b ]) tail
        | Space s -> (
            let last_item = remove_last_item tail in
            match last_item with
            | None -> acc
            | Some (item, remaining_fs) -> (
                match item with
                | Space _ -> loop acc ([ head ] @ remaining_fs)
                | Block b -> (
                    match s.amount - b.amount with
                    | 0 -> loop (acc @ [ Block b ]) remaining_fs
                    | n when n < 0 ->
                        loop
                          (acc @ [ Block { amount = s.amount; id = b.id } ])
                          (remaining_fs @ [ Block { amount = -n; id = b.id } ])
                    | n when n > 0 ->
                        loop
                          (acc @ [ Block { amount = b.amount; id = b.id } ])
                          ([ Space { amount = n } ] @ remaining_fs)
                    | _ -> raise (Invalid_argument "")))))
  in
  loop [] fs

let arithmatic_series a n di =
  let af = float_of_int a in
  let nf = float_of_int n in
  let d = float_of_int di in
  Float.mul (Float.div nf 2.0)
    (Float.add (Float.mul 2.0 af) (Float.mul (Float.sub nf 1.0) d))
  |> int_of_float

let checksum l =
  let rec loop sum index l' =
    match l' with
    | [] -> sum
    | head :: tail -> (
        match head with
        | Space s -> loop sum (index + s.amount) tail
        | Block b ->
            loop
              (sum + arithmatic_series (index * b.id) b.amount b.id)
              (index + b.amount) tail)
  in
  loop 0 0 l

let solve lines =
  let line = List.nth lines 0 in
  let expanded_fs = expand_file_system line in
  let compresed_fs = defrag_file_system expanded_fs in
  let part1 = checksum compresed_fs in
  (part1, 0)
