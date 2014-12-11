open Core.Std

let copy_file to_path from_path = 

	let to_file_path = to_path^"/"^from_path in 
	let in_ch = In_channel.create from_path in 
	let out_ch = Out_channel.create to_file_path in 
	Out_channel.output_string out_ch (In_channel.input_all in_ch) ;
	Out_channel.flush out_ch;
	Out_channel.close out_ch;
	In_channel.close in_ch


let copy_dir to_path from_path = 
	()

let copy to_path from_path = 
	if Sys.is_directory_exn from_path
	then copy_dir to_path from_path
	else copy_file to_path from_path

let main () = 
	let cwd = Sys.getcwd () in 
	let copy_to = cwd ^ ".bak" in
	Unix.mkdir copy_to;
	let dir_list = Sys.ls_dir cwd in 
	List.iter ~f:(copy copy_to) dir_list 
	


let () = 
	main ()
