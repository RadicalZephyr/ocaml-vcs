open Core.Std

let ensure_dir_exists dir =
  match Sys.file_exists dir with
  | `Yes | `Unknown -> ()
  | `No ->
     Unix.mkdir dir

let copy_file from_path to_path =
  let in_ch = In_channel.create from_path in
  let out_ch = Out_channel.create to_path in
  In_channel.iter_lines in_ch ~f:(Out_channel.output_string out_ch);
  In_channel.close in_ch;
  Out_channel.close out_ch

let rec copy_dir from_path to_path =
  ensure_dir_exists to_path;
  Sys.ls_dir from_path
  |> List.iter ~f:(fun item ->
                   copy from_path to_path item)

and copy from_root to_root item =
  let from_path = Filename.concat from_root item in
  let   to_path = Filename.concat   to_root item in
  match Sys.is_directory from_path with
  | `Unknown -> ()
  | `No -> copy_file from_path to_path
  | `Yes -> copy_dir from_path to_path


let main () =
  let cwd = Sys.getcwd () in
  let root = Filename.dirname cwd in
  let dst = Filename.concat root ".myvcs" in
  ensure_dir_exists dst;
  copy cwd dst "."


let () =
  main ()
