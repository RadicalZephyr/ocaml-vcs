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

let delete_dir_contents directory =
  Sys.ls_dir directory
  |> List.iter ~f:Unix.remove

let match_last inputList =
  match List.last inputList with
  | None -> 0
  | Some x -> x

let root_backup_dir root =
  Filename.concat root ".myvcs"

let latest_backup_revision root =
  Sys.ls_dir (root_backup_dir root)
  |>  List.map ~f:Int.of_string
  |> List.sort ~cmp:Int.compare
  |> match_last

let backup_path root rev =
  let backup_root = root_backup_dir root in
  rev
  |> Int.to_string
  |> Filename.concat backup_root

let next_backup_path root latest_rev =
  Int.succ latest_rev
  |> backup_path root

let find_backup_folder root revnum =
  let backup_dir = root_backup_dir root in
  match Sys.file_exists backup_dir with
  | `No | `Unknown -> invalid_arg "Root Backup folder .myvcs does not exist"
  | `Yes ->
      let backup_version = Filename.concat backup_dir (Int.to_string revnum) in
      match Sys.file_exists backup_version with
      | `No | `Unknown -> invalid_arg (sprintf "Backup Version %d does not exist" revnum)
      | `Yes -> backup_version

let backup () =
  let cwd = Sys.getcwd () in
  let root = Filename.dirname cwd in
  let latest_rev = latest_backup_revision root in
  let new_backup = next_backup_path root latest_rev in
  printf "Backing up into folder %s\n" new_backup;
  ensure_dir_exists new_backup;
  copy cwd new_backup "."

let latest () =
  let cwd = Sys.getcwd () in
  let root = Filename.dirname cwd in
  printf "Checking out most recent revision.\n"

let checkout revnum =
  let cwd = Sys.getcwd () in
  let root = Filename.dirname cwd in
  let backup_version = find_backup_folder root revnum in
  printf "Checking out Revision %d\n" revnum;
  delete_dir_contents cwd ;
  copy backup_version cwd "."

let backup_command =
  Command.basic ~summary:""
                Command.Spec.empty
                backup

let latest_command =
  Command.basic ~summary:"Checkout the most recent backup."
                Command.Spec.empty
                latest

let checkout_command =
  Command.basic
    ~summary:""
    Command.Spec.(empty
                  +> anon ("revnum" %: int))
    (fun revnum () -> checkout revnum)

let command =
  Command.group
    ~summary:"Backup your stuff!"
    ["backup", backup_command;
     "checkout", checkout_command;
     "latest", latest_command]

let () =
  Command.run ~version:"0.1" ~build_info:"" command
