open Core.Std

let ensure_dir_exists dir =
  match Sys.file_exists dir with
  | `Yes | `Unknown -> ()
  | `No ->
     Unix.mkdir dir

let copy_file from_path to_path =
  let in_ch = In_channel.create from_path in
  let out_ch = Out_channel.create to_path in
  let len = 4096 in
  let buf = String.create len in

  let rec copy () =
    match In_channel.input in_ch ~buf ~pos:0 ~len with
    | 0 -> ()
    | len ->
       Out_channel.output out_ch ~buf ~pos:0 ~len;
       copy ()
  in

  copy ();
  In_channel.close in_ch;
  Out_channel.close out_ch


let rec copy from_root to_root item =
  let from_path = Filename.concat from_root item in
  let   to_path = Filename.concat   to_root item in
  match Sys.is_directory from_path with
  | `Unknown -> ()
  | `No -> copy_file from_path to_path
  | `Yes ->
     ensure_dir_exists to_path;
     Sys.ls_dir from_path
     |> List.iter ~f:(fun item ->
                      copy from_path to_path item)
let match_last inputList =
  match List.last inputList with
  | None -> 0
  | Some x -> x



let backup_name root =
  let backup_dir = Filename.concat root ".myvcs" in
  ensure_dir_exists backup_dir;
  Sys.ls_dir backup_dir
  |>  List.map ~f:Int.of_string
  |> List.sort ~cmp:Int.compare
  |> match_last
  |> Int.succ
  |> Int.to_string
  |> Filename.concat backup_dir





let main () =
  let cwd = Sys.getcwd () in
  let root = Filename.dirname cwd in
  let new_backup = backup_name root in
  ensure_dir_exists new_backup;
  print_string new_backup;
  copy cwd new_backup "."


let () =
  main ()
