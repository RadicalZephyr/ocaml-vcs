open Core.Std


let copy_file to_path from_path = 
	(*In_channel.with_file path ~f:*)
	()

let copy_dir to_path from_path = 
	()

let copy to_path from_path = 
	if Sys.is_directory_exn from_path
	then copy_dir to_path from_path
	else copy_file to_path from_path

let main () = 
	let cwd = Sys.getcwd () in 
	let copy_to = cwd ^ ".bak" in 
	let dir_list = Sys.ls_dir cwd in 
	List.iter ~f:(copy copy_to) dir_list 
	


let () = 
	main ()
